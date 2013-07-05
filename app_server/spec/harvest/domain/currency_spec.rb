require 'spec_helper'

require 'harvest/domain/currency'

module Harvest
  module Domain
    describe Currency do
      subject(:currency) { Currency.new("GBP", 10) }

      describe ".dollar" do
        subject(:dollar_currency) { Currency.dollar(5) }

        its(:to_s) { should be == "$5" }
      end

      describe "#==" do
        it "is defined" do
          expect(currency).to be == Currency.new("GBP", 10)
        end

        it "matches on symbol" do
          expect(currency).to_not be == Currency.new("X", 10)
        end

        it "matches on amount" do
          expect(currency).to_not be == Currency.new("GBP", 999)
        end

        it "can't be compared to the equivalent Integer" do
          expect {
            currency == 10
          }.to raise_error(TypeError) { |error|
            expect(error.message).to include("can't convert Fixnum into Currency")
          }
        end
      end

      describe "#+" do
        it "adds the amounts" do
          expect(currency + Currency.new("GBP", 5)).to be == Currency.new("GBP", 15)
        end

        it "can't be added to an Integer" do
          expect {
            currency + 5
          }.to raise_error(TypeError) { |error|
            expect(error.message).to include("can't convert Fixnum into Currency")
          }
        end

        it "can't be added to a different currency" do
          expect {
            currency + Currency.new("USD", 5)
          }.to raise_error(Currency::CurrencyConversionError) { |error|
            expect(error.message).to include("Can't convert USD into GBP")
          }
        end
      end
    end
  end
end