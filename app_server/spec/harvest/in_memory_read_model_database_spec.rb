require 'spec_helper'

require 'harvest/in_memory_read_model_database'

describe InMemoryReadModelDatabase do
	subject(:database) { InMemoryReadModelDatabase.new }

  describe "#count" do
    it "counts the number of saved rows" do
      database.save(unused: "data")
      database.save(unused: "data")
      database.save(unused: "data")

      expect(database.count).to be == 3
    end

    context "after deleting existing rows" do
      it "doesn't count deleted rows" do
        database.save(foo: "bar")
        database.save(cow: "moo")
        database.save(key: "value")

        database.delete(foo: "bar")

        expect(database.count).to be == 2
      end
    end
  end

  describe "update" do
    before(:each) do
      database.save(a: "1", b: "2", c: "3")
      database.save(a: "1", b: "9", c: "3")
    end

    context "a unique record matches" do
      it "updates the record" do
        database.update([ :a, :b ], a: "1", b: "2", c: "changed")

        expect(database.records).to be == [
          { a: "1", b: "2", c: "changed" },
          { a: "1", b: "9", c: "3" }
        ]
      end
    end

    context "record is not found" do
      it "raises an error" do
        expect {
          database.update([ :a, :b ], a: "wrong_a", b: "wrong_b", c: "not used")
        }.to raise_error(InMemoryReadModelDatabase::RecordNotFoundError) { |error|
          expect(error.message).to include("No records matched", "a", "wrong_a", "b", "wrong_b")
        }
      end
    end

    context "record is not uniquely identified" do
      it "raises an error" do
        expect {
          database.update([ :a, :c ], a: "1", b: "changed", c: "3")
        }.to raise_error(InMemoryReadModelDatabase::NonUniqueUpdateError) { |error|
          expect(error.message).to include("Multiple records matched", "a", "1", "c", "3")
        }
      end
    end
  end

  describe "#delete" do
    before(:each) do
      database.save(foo: "bar", baz: "quux")
    end

    it "deletes where all attributes match" do
      expect {
        database.delete(foo: "bar", baz: "quux")
      }.to change { database.count }.from(1).to(0)
    end

    it "doesn't deletes where attribute doesn't match" do
      expect {
        database.delete(foo: "bar", baz: "moo")
      }.to_not change { database.count }
    end

    it "deletes where a subset of attributes match" do
      expect {
        database.delete(foo: "bar", baz: "quux")
      }.to change { database.count }.from(1).to(0)
    end
  end

  describe "#records" do
    it "returns all saved data" do
      database.save(foo: "bar")
      database.save(cow: "moo")
      database.save(key: "value")

      expect(database.records).to be == [
				{ foo: "bar" 		},
				{ cow: "moo" 		},
				{ key: "value" 	}
      ]
    end
  end
end