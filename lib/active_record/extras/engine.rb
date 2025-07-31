require 'active_record/extras/association_scopes'

module ActiveRecord
  module Extras
    class Engine < ::Rails::Engine
      initializer "active_record.extras.active_record_integration" do
        ActiveSupport.on_load(:active_record) do
          include ActiveRecord::Extras::AssociationScopes
        end
      end
    end
  end
end
