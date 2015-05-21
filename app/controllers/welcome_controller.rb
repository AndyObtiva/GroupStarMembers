class WelcomeController < ApplicationController
  def index
    #page_token = ApplicationSetting.find_by_name('FACEBOOK_PAGE_TOKEN')
    #if page_token.nil?
      @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], ENV['FACEBOOK_CALLBACK_URL'])
      user_token = ApplicationSetting.find_by_name('FACEBOOK_USER_TOKEN')
      if user_token.nil?
        Rails.logger.info "params['code']"
        Rails.logger.info params['code']

        #puts 'cookies.inspect'
        #puts cookies.inspect
        #user = @oauth.get_user_info_from_cookies(cookies)
        #puts 'user.inspect'
        #puts user.inspect
        #if user.nil?
        #  return #let JS API take care of this
        #end

        if params['code']
          user_token_value = @oauth.get_access_token(params['code'])
          user_token = ApplicationSetting.create!(name: 'FACEBOOK_USER_TOKEN', value: user_token_value)
        else
          oauth_url = @oauth.url_for_oauth_code
          Rails.logger.info 'oauth_url'
          Rails.logger.info oauth_url
          redirect_to(oauth_url) && return
        end
      end
      render(text: 'No user token found!') && return if user_token.nil?

      begin
        new_user_token_info = @oauth.exchange_access_token_info(user_token.value)
      rescue => e
        user_token.destroy
        raise e
      end

      Rails.logger.error "user token value"
      Rails.logger.error user_token.value

      if new_user_token_info.nil?
        user_token.destroy
        redirect_to(action: index)
      else
        user_token.update_attribute(:value, new_user_token_info['access_token'])
      end

      Rails.logger.error "new user token value"
      Rails.logger.error user_token.value
      user_graph = Koala::Facebook::API.new(user_token.value)
      accounts = user_graph.get_connections('me', 'accounts')
      Rails.logger.error 'accounts.inspect'
      Rails.logger.error accounts.inspect
      facebook_page_account = accounts.detect {|account| account['id'] == ENV['FACEBOOK_PAGE_ID']}
      page_token_value = facebook_page_account && facebook_page_account['access_token']
      render(text: 'No page token value found!') && return if page_token_value.nil?
      page_token = ApplicationSetting.find_or_create_by(name: 'FACEBOOK_PAGE_TOKEN') do |setting|
        setting.value = page_token_value
      end
    #end

    @page_graph = Koala::Facebook::API.new(page_token.value)
    @ratings = @page_graph.get_connections(ENV['FACEBOOK_PAGE_ID'], 'ratings')
  end
end
