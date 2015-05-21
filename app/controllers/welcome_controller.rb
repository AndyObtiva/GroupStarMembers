class WelcomeController < ApplicationController
  def index
    page_token = ApplicationSetting.find_by_name('FACEBOOK_PAGE_TOKEN')
    if page_token.nil?
      @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], ENV['FACEBOOK_CALLBACK_URL'])
      #@user = @oauth.get_user_info_from_cookies(cookies)
      user_token = ApplicationSetting.find_by_name('FACEBOOK_USER_TOKEN')
      if user_token.nil?
        puts "params['code']"
        puts params['code']
        if params['code']
          user_token_value = @oauth.get_access_token(params['code'])
          user_token = ApplicationSetting.create!(name: 'FACEBOOK_USER_TOKEN', value: user_token_value)
        else
          redirect_to(@oauth.url_for_oauth_code)
        end
      end
      return if user_token.nil?
      user_graph = Koala::Facebook::API.new(user_token.value)
      accounts = user_graph.get_connections('me', 'accounts')
      page_token_value = @user_graph.get_connections('me', 'accounts').detect {|account| account['id'] == ENV['FACEBOOK_PAGE_ID']}['access_token']
      page_token = ApplicationSetting.create!(name: 'FACEBOOK_PAGE_TOKEN', value: page_token_value)
    end
    @page_graph = Koala::Facebook::API.new(page_token)
    @ratings = @page_graph.get_connections(ENV['FACEBOOK_PAGE_ID'], 'ratings')
  end
end
