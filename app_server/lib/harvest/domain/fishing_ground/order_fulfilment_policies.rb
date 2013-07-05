module Harvest
  module Domain
    class FishingGround
      module OrderFulfilmentPolicies
        # Mixin to provide a simple (albeit Template Method) API,
        # just implement #each to use
        module OrderFulfilmentPolicy
          module ClassMethods
            def wrap(target)
              new(target)
            end
          end

          module InstanceMethods
            def initialize(target)
              @target = target
            end
          end

          def self.included(receiver)
            receiver.extend         ClassMethods
            receiver.send :include, InstanceMethods
          end
        end

        # Fill orders in the sequence they were received
        class Sequential
          include OrderFulfilmentPolicy

          def each(&block)
            @target.each(&block)
          end
        end

        # Fill orders randomly (the original game rules)
        class Random
          include OrderFulfilmentPolicy

          def each(&block)
            @target.keys.shuffle.each do |key|
              yield(key, @target[key])
            end
          end
        end
      end
    end
  end
end