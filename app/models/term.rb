require 'master_forest'

class Term < ActiveRecord::Base
  attr_accessible :reduction_status, :serialized
  enum_attr :reduction_status,
    %w(^not_started pending success term_too_large reduction_too_deep normal_form)
  validates :serialized, presence: true
  validate :syntactically_valid
  validate :successful_reduction_has_redux

  has_one :redux, class_name: "Term", foreign_key: "redux_id"

  def maximum_reduction_depth
    ENV['CLACHE_MAX_REDUCTION_DEPTH'] || 5000
  end

  def maximum_term_length
    ENV['CLACHE_MAX_TERM_LENGTH'] || 2**16
  end

  def reduce
    self.reduction_status = :pending
    save

    cur     = MasterForest::Term.new serialized
    redices = []
    1.upto(maximum_reduction_depth) do
      known_term = Term.find_by_serialized cur.to_s
      if known_term and known_term.reduction_status != :pending
        return memoize redices, known_term.reduction_status, known_term.redux
      end

      reduced = cur.reduce
      if reduced.to_s.length > maximum_term_length
        memoize redices, :term_too_large, nil
      end
      if reduced.normal?
        t = Term.find_or_create_by_serialized reduced.to_s
        t.reduction_status = :normal_form
        t.save
        return memoize redices, :success, t
      else
        redices << reduced
      end
      cur = reduced
    end

    memoize redices, :reduction_too_deep, nil
  end

  handle_asynchronously :reduce

  private

  def syntactically_valid
    unless (MasterForest::Term.new serialized).valid?
      errors.add :serialized, "is not syntactically correct"
    end
  end

  def successful_reduction_has_redux
    if reduction_status == :success and redux.nil?
      errors.add :reduction_status, "cannot be successful since redux is nil"
    end
  end

  def memoize redices, status, redux
    redices.each do |redex|
      t                  = Term.create serialized: redex.to_s
      t.redux            = redux
      t.reduction_status = status
      t.save
    end
    self.redux            = redux
    self.reduction_status = status
    self.save
  end

end
