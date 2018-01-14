# Prevent long running select count queries for choosen tables, and preserve the oryginal behaviour for other tables
module Kaminari
  module PageScopeMethods
    def total_count(column_name = :all, options = {})
      if ActiveAdmin.application.dont_count.include?(entry_name.titleize.gsub(" ", "").tableize)
        2000000
      else
        @total_count ||= begin
          c = except(:offset, :limit, :order)

          # Remove includes only if they are irrelevant
          c = c.except(:includes) unless references_eager_loaded_tables?

          # Rails 4.1 removes the `options` argument from AR::Relation#count
          args = [column_name]
          args << options if ActiveRecord::VERSION::STRING < '4.1.0'

          # .group returns an OrderdHash that responds to #count
          c = c.count(*args)
          if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
            c.count
          else
            c.respond_to?(:count) ? c.count(*args) : c
          end
        end
      end
    end
  end
end
