require_relative "test_helper"

class AssociationScopesTest < Minitest::Test
  def setup
    @user_with_posts = User.create!(name: "with posts")
    @user_without_posts = User.create!(name: "no posts")

    Post.create!(title: "first", user: @user_with_posts)
    Post.create!(title: "second", user: @user_with_posts)

    Role.create!(user: @user_with_posts, role_name: "admin")
  end

  def test_with_existing
    users = User.with_existing(:posts)
    assert_includes users.map(&:id), @user_with_posts.id
    refute_includes users.map(&:id), @user_without_posts.id
  end

  def test_without_existing
    users = User.without_existing(:posts)
    assert_includes users.map(&:id), @user_without_posts.id
    refute_includes users.map(&:id), @user_with_posts.id
  end

  def test_with_counts
    user = User.
      with_counts(:posts, :roles).
      find(@user_with_posts.id)

    refute_empty @user_with_posts.posts
    assert_equal @user_with_posts.posts.count, user.posts_count
    assert_equal @user_with_posts.roles.count, user.roles_count
  end

  def test_with_extra_conditions
    user = User.with_counts(:posts) do |join_conditions, target_table|
      join_conditions.and(target_table[:title].eq("first"))
    end.find(@user_with_posts.id)

    matching_posts = @user_with_posts.posts.select { |p| p.title == "first" }
    assert_equal matching_posts.count, user.posts_count
  end

  def test_exists_association_sql
    sql = User.where(User.exists_association(:posts)).to_sql
    assert_includes sql.downcase, "exists"
    assert_includes sql, "posts"
  end
end