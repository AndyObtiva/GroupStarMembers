class WelcomeController < ApplicationController
  def index
    page_token = ApplicationSetting.find_by_name('FACEBOOK_PAGE_TOKEN')
    if page_token.nil?
      @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], ENV['FACEBOOK_CALLBACK_URL'])
      #@user = @oauth.get_user_info_from_cookies(cookies)
      user_token = ApplicationSetting.find_by_name('FACEBOOK_USER_TOKEN')
      if user_token.nil?
        puts 'request'
        puts request.inspect
        puts 'request.url'
        puts request.url
        puts "params"
        puts params.inspect
        puts "params['token']"
        puts params['token']
        if params['token']
          user_token = ApplicationSetting.create!(name: 'FACEBOOK_USER_TOKEN', value: params['token'])
        elsif !request.url.include?('token')
          oauth_url = @oauth.url_for_oauth_code + "&response_type=token"
          puts 'oauth_url'
          puts oauth_url
          redirect_to(oauth_url)
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
