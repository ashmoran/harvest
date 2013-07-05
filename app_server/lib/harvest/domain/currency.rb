module Harvest
  module Domain
    # A simple value type to represent currency amounts
    class Currency
      class CurrencyConversionError < TypeError
        def initialize(from_symbol, to_symbol)
          @from_symbol = from_symbol
          @to_symbol = to_symbol
        end

        def message
          "Can't convert #{@from_symbol} into #{@to_symbol}"
        end
      end

      class << self
        def dollar(amount)
          new("$", amount)
        end
      end

      def initialize(symbol, amount)
        @symbol = symbol
        @amount = amount
      end

      def to_s
        "#{@symbol}#{@amount}"
      end

      def +(other)
        assert_duck_type(other, :add_currency)
        other.add_currency(@symbol, @amount)
      end

      def ==(other)
        assert_duck_type(other, :has_same_currency_elements?)
        other.has_same_currency_elements?(@symbol, @amount)
      end

      protected

      def add_currency(other_symbol, other_amount)
        if !(@symbol == other_symbol)
          raise CurrencyConversionError.new(@symbol, other_symbol)
        end
        self.class.new(@symbol, @amount + other_amount)
      end

      def has_same_currency_elements?(symbol, amount)
        symbol == @symbol && amount == @amount
      end

      private

      def assert_duck_type(target, message_name)
        if !target.respond_to?(message_name, _include_protected=true)
          raise TypeError.new("can't convert #{target.class} into Currency")
        end
      end
    end
  end
end