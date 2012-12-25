class SubmittedUrlsController < ApplicationController
  
  def index 
    default_user = {:fullname => "Anonymous", :email => "anonymous@have.not"}
    @submitted_urls = SubmittedUrl.desc(:created_at)
    @submitted_urls.each_with_index do |item, i| 
      if not item.user_id.nil? 
        @submitted_urls[i-1][:user] = User.find_by_id(item.user_id)
      else
        @submitted_urls[i-1][:user] = User.new default_user
      end
    end
  end

  def create
    success = false
    user_id = current_user.id unless current_user.nil?
    new_submitted_url = SubmittedUrl.new  :user_id  => user_id, 
                                          :url      =>  params[:url],
                                          :message   => params[:message]
    captcha_result = params[:value_a].to_i + params[:value_b].to_i
    
    if current_user 
      success = new_submitted_url.save
    elsif (not params[:fb_math].nil? and (captcha_result == params[:fb_math].to_i) )
       success = new_submitted_url.save
    end
    if success
      flash[:notice] = "Many thanks for your submission. We will integrate it is soon as possible."
    else
      flash[:error] = "Cant save url - not valid content."
    end
  end

end