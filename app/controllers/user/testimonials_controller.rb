class User::TestimonialsController < ApplicationController

  before_filter :authenticate, only: [:create, :update]

  def index
    @testimonial = Testimonial.new
  end

  def show
    if signed_in?
      @user = current_user
      @testimonial = @user.testimonial || Testimonial.new
    else
      @testimonial = Testimonial.new
    end
  end

  def create
    new_testimonial = Testimonial.new(params[:testimonial])
    new_testimonial.user_id = current_user.id

    if new_testimonial.save(validate: false)
      flash[:success] = "Your testimonial is added successfully!"
    else
      flash[:error] = "Our database refused to save your testimonial."
    end
    redirect_to action: 'show'
  end

  def update
    testimonial = Testimonial.find_by_id(params[:testimonial][:_id])
    if testimonial.nil?
      flash[:error] = "Cant update - someone stole id of your testimony."
      redirect_to :back and return
    end
    testimonial.update_attributes!(params[:testimonial])
    if testimonial.save
      flash[:success] = "Your's testimonial is now updated."
    else
      flash[:error] = "Sorry! Cant save your updates."
    end
    redirect_to action: 'show'
  end

end
