require 'spec_helper'

require 'harvest/domain/fishing_ground/order_fulfilment_policies'

module Harvest
  module Domain
    class FishingGround
      module OrderFulfilmentPolicies
        describe OrderFulfilmentPolicies do
          let(:target) {
            { "a" => 1, "g" => 7, "b" => 2, "e" => 5, "d" => 4, "c" => 3, "f" => 6 }.freeze
          }

          let(:collected_keys) { [ ] }
          let(:collected_values) { [ ] }

          def apply
            enumerator.each do |key, value|
              collected_keys << key
              collected_values << value
            end
          end

          before(:each) do
            apply
          end

          describe Sequential do
            subject(:enumerator) { OrderFulfilmentPolicies::Sequential.wrap(target) }

            it "enumerates according to the order elements were added" do
              expect(collected_keys).to   be == %w[ a g b e d c f ]
              expect(collected_values).to be == [ 1, 7, 2, 5, 4, 3, 6 ]
            end
          end

          describe Random do
            subject(:enumerator) { OrderFulfilmentPolicies::Random.wrap(target) }

            it "enumerates a shuffled version of the elements" do
              expect(collected_keys.sort).to   be == %w[ a b c d e f g ]
              expect(collected_values.sort).to be == [ 1, 2, 3, 4, 5, 6, 7 ]

              expect(collected_keys).to_not   be == %w[ a g b e d c f ]
              expect(collected_values).to_not be == [ 1, 7, 2, 5, 4, 3, 6 ]
            end
          end
        end
      end
    end
  end
end