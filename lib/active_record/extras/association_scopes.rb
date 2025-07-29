module ActiveRecord
  module Extras
    module AssociationScopes
      extend ActiveSupport::Concern

      class_methods do
        # Builds a subquery for a has_many association.
        # Can be used to generate EXISTS or COUNT subqueries.
        #
        # @param association_name [Symbol, String] the name of the has_many association
        # @param mode [:exists, :count] determines the kind of subquery
        # @yield [join_conditions, target_table] optional block to modify the join conditions
        # @return [Arel::Nodes::SqlLiteral] the subquery as an Arel node
        def association_subquery(association_name, mode: :exists, &extra_conditions_block)
          reflection = reflections[association_name.to_s]

          unless reflection
            raise ArgumentError, "Unknown association: #{association_name}"
          end

          unless reflection.macro == :has_many
            raise ArgumentError, "Only has_many associations are supported (got #{reflection.macro})"
          end

          foreign_keys = Array(reflection.foreign_key)
          primary_keys = Array(reflection.active_record_primary_key)

          unless foreign_keys.size == primary_keys.size
            raise ArgumentError, "Mismatch in key counts: #{foreign_keys} vs #{primary_keys}"
          end

          source_table = arel_table
          target_table = reflection.klass.arel_table

          join_conditions = foreign_keys.zip(primary_keys).map do |fk, pk|
            target_table[fk].eq(source_table[pk])
          end.reduce(&:and)

          # Allow caller to modify the join condition via block
          if extra_conditions_block
            new_conditions = extra_conditions_block.call(join_conditions, target_table)
            join_conditions = new_conditions if new_conditions
          end

          case mode
          when :exists
            target_table.project(Arel.sql("1")).where(join_conditions).exists
          when :count
            Arel::Nodes::Grouping.new(
              target_table.project(Arel.star.count).where(join_conditions)
            )
          else
            raise ArgumentError, "Unknown mode: #{mode.inspect} (expected :exists or :count)"
          end
        end

        # Builds an EXISTS subquery for the given association.
        # Shorthand for association_subquery(..., mode: :exists)
        def exists_association(association_name, &block)
          association_subquery(association_name, mode: :exists, &block)
        end

        # Builds a COUNT subquery for the given association.
        # Shorthand for association_subquery(..., mode: :count)
        def count_association(association_name, &block)
          association_subquery(association_name, mode: :count, &block)
        end

        # Adds a WHERE EXISTS (...) clause for the given association.
        #
        # Example:
        #   User.with_existing(:posts)
        def with_existing(association_name, &block)
          where(exists_association(association_name, &block))
        end

        # Adds a WHERE NOT EXISTS (...) clause for the given association.
        #
        # Example:
        #   User.without_existing(:comments)
        def without_existing (association_name, &block)
          where.not(exists_association(association_name, &block))
        end

        # Selects all columns plus COUNT subqueries for the given associations.
        #
        # Example:
        #   User.with_counts(:posts, :comments)
        #
        # Produces:
        #   SELECT users.*, (SELECT COUNT(*) FROM posts WHERE ...) AS posts_count,
        #                      (SELECT COUNT(*) FROM comments WHERE ...) AS comments_count
        def with_counts (*association_names, &block)
          selections = [arel_table[Arel.star]] +
                       association_names.map do |name|
                         count_association(name, &block).as("#{name}_count")
                       end

          select(*selections)
        end
      end

    end
  end
end