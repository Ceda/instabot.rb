require 'instabot'

Config.setup do |set|
  set.username                = 'ceda_test'
  set.password                = 'Cedak123'
  set.tags                    = ['machovojezero', 'machac', 'czechrepublic', 'czech']
  set.wait_per_action         = 1 * 60 # => seconds
  set.max_like_per_day        = 50
  set.max_follow_per_day      = 50
  set.max_unfollow_per_day    = 50
  set.max_comment_per_day     = 50
  set.pretty_print 	          = true
  set.infinite_tags           = true
  set.print_banner            = true
  set.pre_load                = false
  set.comments                = [
    ['this', 'the', 'your'],
    ['photo', 'picture', 'pic', 'shot', 'snapshot'],
    ['is', 'looks', 'feels', 'is really'],
    ['great', 'super', 'good', 'very good', 'good', 'wow', 'WOW', 'cool', 'GREAT','magnificent','magical', 'very cool', 'stylish', 'beautiful','so beautiful', 'so stylish','so professional','lovely', 'so lovely','very lovely', 'glorious','so glorious','very glorious', 'adorable', 'excellent','amazing'],
    ['.', '..', '...', '!', '!!', '!!!']
  ]
end

bot = Instabot.new
bot.mode(:infinite)


require 'instabot'
bot = Instabot.new :manual

bot.login('ceda_test', 'Cedak123')

bot.follow('276845211')
bot.get_user_informations('276845211')
bot.search_by_tags(['machovojezero'])
# bot.unfollow(11111111) # user id
# bot.like(1111111) # media id
# bot.comment(1111111, "comment text here") # media id

bot.logout


bot.search(['machovojezero'])

bot = Instabot.new :manual
bot.media_to_follow(['machovojezero'])
