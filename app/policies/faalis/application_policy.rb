# Main class for all the **Faalis** Policy classes.
# It's totally a minimume Policy.
class Faalis::ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    return false if @user.nil?
    return true if @user.admin?
    false
  end

  def show?
    return false if @user.nil?
    return true if @user.admin?
    false
  end

  def create?
    return false if @user.nil?
    return true if @user.admin?
    false
  end

  def new?
    create?
  end

  def update?
    return false if @user.nil?
    return true if @user.admin?
    false
  end

  def edit?
    update?
  end

  def destroy?
    return false if @user.nil?
    return true if @user.admin?
    false
  end

  def scope
    Pundit.policy_scope!(@user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @@user = @user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
