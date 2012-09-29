class Term < ActiveRecord::Base
  attr_accessible :reduction_status, :serialized
  enum_attr :reduction_status, %w(^not_started pending complete term_too_large reduction_too_deep)
  validates :serialized, presence: true
  validate :syntactically_valid

  has_one :redux, class_name: "Term", foreign_key: "redux_id"

  def maximum_reduction_depth
    10000
  end

  def maximum_term_length
    2**20
  end

  def reduce
    reduction_status = :pending
    save

    cur     = MasterForest::Term.new serialized
    redices = [cur]
    1.upto(maximum_reduction_depth) do
      known_term = Term.find_by_serialized cur.to_s
      if known_term and known_term.redux.present?
        memoize redices, :success, known_term.redux
        return
      end

      reduced = cur.reduce
      if reduced.to_s.length > maximum_term_length
        memoize redices, :term_too_large, nil
      end
      if reduced.normal?
        t = Term.find_or_create_by_serialized reduced.to_s
        memoize redices, :success, t
        return
      else
        redices << reduced
      end
      cur = reduced
    end

    reduction_status = :reduction_too_deep
    save
  end
  handle_asynchronously :reduce

  private
  def syntactically_valid
    unless (MasterForest::Term.new serialized).valid?
      errors.add(:serialized, "is not syntactically correct")
    end
  end

  def memoize redices, status, redux
    redices.each do |serialized_redex|
      t                  = Term.find_or_create_by_serialized serialized_redex
      t.redux            = redux
      t.reduction_status = status
      t.save
    end
  end

end
