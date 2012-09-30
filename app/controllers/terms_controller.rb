class TermsController < ApplicationController
  def new
    @term = Term.new
  end

  def create
    @term = Term.new params[:term]
    if @term.save
      @term.reduce
      redirect_to @term, status: 303 # see other
    else
      render status: 400 # bad request
    end
  end

  def index
    @q = Term.search params[:q]
    @terms = @q.result.paginate page: params[:page]
  end

  def show
    @term = Term.find params[:id]
    if @term.nil?
      render file: "#{RAILS_ROOT}/public/404.html", status: 404
    else
      case @term.reduction_status
      when :not_started
      when :pending
        render status: 202 # accepted
      when :term_too_large
      when :reduction_too_deep
        render status: 413 # request entity too large
      end
    end
  end
end
