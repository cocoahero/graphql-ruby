# frozen_string_literal: true

module GraphQL
  class Schema
    class Member
      module HasDataloader
        # @return [GraphQL::Dataloader] The dataloader for the currently-running query
        def dataloader
          context.dataloader
        end

        # Find an object with ActiveRecord via {Dataloader::ActiveRecordSource}.
        # @param model [Class<ActiveRecord::Base>]
        # @param find_by_value [Object] Usually an `id`, might be another value if `find_by:` is also provided
        # @param find_by [Symbol, String] A column name to look the record up by. (Defaults to the model's primary key.)
        # @return [ActiveRecord::Base, nil]
        def dataload_record(model, find_by_value, find_by: nil)
          source = if find_by
            dataloader.with(Dataloader::ActiveRecordSource, model, find_by: find_by)
          else
            dataloader.with(Dataloader::ActiveRecordSource, model)
          end

          source.load(find_by_value)
        end

        # Look up an associated record using a Rails association.
        # @param association_name [Symbol] A `belongs_to` or `has_one` association. (If a `has_many` association is named here, it will be selected without pagination.)
        # @param record [ActiveRecord::Base] The object that the association belongs to.
        # @param scope [ActiveRecord::Relation] A scope to look up the associated record in
        # @return [ActiveRecord::Base, nil] The associated record, if there is one
        # @example Looking up a belongs_to on the current object
        #    dataload_association(:parent) # Equivalent to `object.parent`, but dataloaded
        # @example Looking up an associated record on some other object
        #    dataload_association(:post, comment) # Equivalent to `comment.post`, but dataloaded
        def dataload_association(association_name, record = object, scope: nil)
          source = if scope
            dataloader.with(Dataloader::ActiveRecordAssociationSource, association_name, scope: scope)
          else
            dataloader.with(Dataloader::ActiveRecordAssociationSource, association_name)
          end
          source.load(record)
        end
      end
    end
  end
end
