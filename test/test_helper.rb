require "minitest/autorun"
require "active_record"
require_relative "../lib/active_record/extras/association_scopes"

# Set up in-memory SQLite
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Schema
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.string :title
    t.references :user, foreign_key: true
  end

  create_table :roles do |t|
    t.string :role_name
    t.references :user, foreign_key: true
  end
end

# Models
class User < ActiveRecord::Base
  include ActiveRecord::Extras::AssociationScopes
  has_many :posts
  has_many :roles
end

class Post < ActiveRecord::Base
  belongs_to :user
end

class Role < ActiveRecord::Base
  belongs_to :user
end