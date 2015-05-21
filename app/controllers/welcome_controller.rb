class WelcomeController < ApplicationController
  def index
    @page_graph = Koala::Facebook::API.new('CAACEdEose0cBAIbG60owNPPDig7p1Y7FvTZCdsZCLAH6QUKekm7l7SvHPawaWV4qZCZASE8L5hrQgjFbHIBCulG2Pxvkcebe7kZCQo16iry0qEKkY1tbADwcDjXrq7EwmH86X6Ti0O57CDcl4bXuKC9YLLVP6eYyLJBjJlm3zCoXZBZBZAZBek4ta3KIlpHIuVfXGGWt7KaEDCAZDZD')
    @ratings = @page_graph.get_connections("1110820932265199", 'ratings')
  end
end
