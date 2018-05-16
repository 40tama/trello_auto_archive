# coding: utf-8
require 'slack'
require 'trello'
require 'date'

# trello
BOARD_ID = '<board_id>'
LIST_NAMES = ['<list_name1>', '<list_name2>', '<list_name3>']
CONSUMER_KEY = '<trello_key>'
CONSUMER_SECRET = '<trello_secret>'
OAUTH_TOKEN = '<trello_token>'

# slack
CHANNEL_NAME = '<channel_name>'
USERNAME = '<user_name>'
TOKEN = '<slack_token>'

Slack.configure do |config|
  config.token = TOKEN
end
Slack.auth_test

def notify_to_slack(text)
  return if text.nil?
  Slack.chat_postMessage text: text, username: USERNAME, channel: CHANNEL_NAME
end

Trello.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = OAUTH_TOKEN
end

board = Trello::Board.find(BOARD_ID)
list_ids = []

board.lists.each do |l|
  list_ids.push(l.id) if LIST_NAMES.include?(l.name)
end

exit if list_ids.nil?
list_ids.each do |l_id|
  list = Trello::List.find(l_id)
  list.cards.each do |c|
    # 期限から7日以上経過したカードをアーカイブ
    # 日本時間には変換していないので注意
    if c.due.present? and c.due.to_date < Date.today - 7
      c.close!
      text = "「#{c.name}」をアーカイブしました"
      print "#{text}\n"
      notify_to_slack(text)
    end
  end
end