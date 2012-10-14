class TermSweeper < ActionController::Caching::Sweeper
  observe Term

  def after_create(term)
    expire_cache_for(term)
  end

  def after_update(term)
    expire_cache_for(term)
  end

  private
  def expire_cache_for(term)
    expire_action(controller: 'terms', action: 'index')
    expire_action(controller: 'terms', action: 'show', id: term.id)
  end
end
