class WelcomeController < ApplicationController
  def index
    @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], 'http://group-star-members.herokuapp.com')
    puts 'Cookies: '
    puts cookies.inspect
    @user = @oauth.get_user_info_from_cookies(cookies)
    puts 'User: '
    puts @user.inspect
    unless @user.nil?
      user_graph = Koala::Facebook::API.new(@user['access_token'])
      accounts = user_graph.get_connections('me', 'accounts')
      page_token = @user_graph.get_connections('me', 'accounts').detect {|account| account['id'] == ENV['FACEBOOK_PAGE_ID']}['access_token']
      @page_graph = Koala::Facebook::API.new(page_token)
      @ratings = @page_graph.get_connections(ENV['FACEBOOK_PAGE_ID'], 'ratings')
    end
  end
end
