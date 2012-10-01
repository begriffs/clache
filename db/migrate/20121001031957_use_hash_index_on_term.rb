class UseHashIndexOnTerm < ActiveRecord::Migration
  def up
    remove_index :terms, name: 'index_terms_on_serialized'
    execute "CREATE INDEX index_terms_on_serialized ON terms USING hash(serialized)"
  end

  def down
    remove_index :terms, name: 'index_terms_on_serialized'
    add_index :terms, :serialized, name: 'index_terms_on_serialized'
  end
end
