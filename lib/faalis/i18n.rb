module ::ActionView
  # = Action View Translation Helpers
  module Helpers
    module TranslationHelper

      def t(key, options = {})
        options = options.dup
        has_default = options.has_key?(:default)
        remaining_defaults = Array(options.delete(:default)).compact

        if has_default && !remaining_defaults.first.kind_of?(Symbol)
          options[:default] = remaining_defaults
        end
        # If the user has explicitly decided to NOT raise errors, pass that option to I18n.
        # Otherwise, tell I18n to raise an exception, which we rescue further in this method.
        # Note: `raise_error` refers to us re-raising the error in this method. I18n is forced to raise by default.
        if options[:raise] == false
          raise_error = false
          i18n_raise = false
        else
          raise_error = options[:raise] || ActionView::Base.raise_on_missing_translations
          i18n_raise = true
        end

        if html_safe_translation_key?(key)
          html_safe_options = options.dup
          options.except(*I18n::RESERVED_KEYS).each do |name, value|
            unless name == :count && value.is_a?(Numeric)
              html_safe_options[name] = ERB::Util.html_escape(value.to_s)
            end
          end
          translation = I18n.translate(scope_key_by_partial(key), html_safe_options.merge(raise: i18n_raise))

          translation.respond_to?(:html_safe) ? translation.html_safe : translation
        else
          I18n.translate(scope_key_by_partial(key), options.merge(raise: i18n_raise))
        end
      rescue I18n::MissingTranslationData => e
        if remaining_defaults.present?
          translate remaining_defaults.shift, options.merge(default: remaining_defaults)
        else
          raise e if raise_error

          keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
          title = keys.last.to_s.humanize
          title = "#{keys.join('.')}" if Faalis::Engine.i18n_debug

          interpolations = options.except(:default, :scope)
          if interpolations.any?
            title << ", " << interpolations.map { |k, v| "#{k}: #{ERB::Util.html_escape(v)}" }.join(', ')
          end

          #content_tag('span', keys.last.to_s.titleize, class: 'translation_missing', title: title)
          title
        end
      end
    end
  end
end

module Faalis
  # I18n related utility functions
  class I18n
    RTL = [:fa, :ar]

    def self.direction(locale)
      RTL.include?(locale.to_sym) ? 'rtl' : 'ltr'
    end

    module Locale
      def self.default_url_options
        { :locale => I18n.locale }
      end
    end

    class MissingKeyHandler < ::I18n::ExceptionHandler
      require 'fileutils'

      def create_key_cache(locale, key)
        locale_dir = "#{Rails.root}/tmp/i18n/#{locale}"
        key_file   = "#{locale_dir}/#{key}"

        FileUtils.mkdir_p locale_dir
        FileUtils.touch [key_file]
      end

      def call(exception, locale, key, options)
        if exception.is_a?(::I18n::MissingTranslation)
          create_key_cache(locale, key)
          super
        else
          super
        end
      end
    end
  end
end
