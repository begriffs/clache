class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.text :serialized
      t.enum :reduction_status
      t.integer :redux_id

      t.timestamps
    end
    change_table :terms do |t|
      t.foreign_key :terms, column: :redux_id
    end

    add_index :terms, :serialized
  end
end
