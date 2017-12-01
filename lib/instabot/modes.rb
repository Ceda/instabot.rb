module Modes
  def mode(mode = :default)
    case mode
    when :infinite
      custom_print '[+] '.cyan + 'Auto mode is turned on'.yellow
      search(options[:tags])
      @next_day = Time.new + 1.days
      puts

      loop do
        if !maximums_are_full?

          if !follows_in_day_are_full?
            @maximums[:follows_in_day] += 1
            @maximums[:likes_in_day]   += 1

            users.each_with_index do |_user, i|
              like medias[i]
              follow users[i]

              custom_puts '[+] '.cyan + "Like array #{i}"

              fall_in_asleep
            end
          else
            custom_puts '[+] '.cyan + 'Maximum follows per day'
          end

          # if !follows_in_day_are_full?
          #   @maximums[:follows_in_day] += 1
          #   auto_follow
          # else
          #   custom_puts '[+] '.cyan + 'Maximum follows per day'
          # end
          #
          # if !unfollows_in_day_are_full?
          #   @maximums[:unfollows_in_day] += 1
          #   auto_unfollow
          # else
          #   custom_puts '[+] '.cyan + 'Maximum unfollows per day'
          # end
          #
          # if !likes_in_day_are_full?
          #   @maximums[:likes_in_day] += 1
          #   auto_like
          # else
          #   custom_puts '[+] '.cyan + 'Maximum likes per day'
          # end
          #
          # if !comments_in_day_are_full?
          #   @maximums[:comments_in_day] += 1
          #   auto_comment
          # else
          #   custom_puts '[+] '.cyan + 'Maximum comments per day'
          # end
        else
          check_date
          sleep 1
        end
      end
    when :clean_up
      custom_puts '[+] '.cyan + 'Clean up mode is turned on'
      @local_stroage[:followed_users].each do |user|
        unfollow(user)
      end
    when :default
      custom_print '[-] '.cyan + 'Please choose a mode'.red
    else
      custom_print '[-] '.cyan + 'Please choose a mode'.red
    end
  end

  def auto_follow
    all_users = users
    id        = 0
    custom_puts '[+] '.cyan + "#{all_users.size} users ready to follow"

    until follows_in_day_are_full?
      begin
        id += 1 if all_users[id].nil? || all_users[id] == []
        get_user_informations(all_users[id])
        custom_puts '[+] '.cyan + "Trying to follow a user [#{all_users[id]}]"
        follow(@informations[:id])
        custom_puts "\n[+] ".cyan + 'User followed!'.green.bold
        @maximums[:follows_in_day] += 1
        id                         += 1
      rescue Exception => e
        puts "an error detected ... #{e} #{e.backtrace}\nignored"
        id += 1
        retry
      end
    end
  end

  def auto_unfollow
    followed_users = @local_stroage[:followed_users]
    id             = 0
    custom_puts '[+] '.cyan + "#{followed_users.size} users ready to unfollow"

    until unfollows_in_day_are_full?
      if @local_stroage[:followed_users].size < @maximums[:max_unfollows_per_day]
        begin
          custom_puts '[+] '.cyan + "Trying to unfollow a user [#{followed_users[id]}]"
          unfollow(followed_users[id])
          custom_puts "\n[+] ".cyan + 'User unfollowed'.bold.green
          @maximums[:unfollows_in_day] += 1
          id                           += 1
          fall_in_asleep
        rescue Exception => e
          puts "an error detected ... #{e}\nignored"
          id += 1
          retry
        end
      else
        custom_print '[+] '.cyan + '[unfollow per day] is bigger than [follow per day]'
        exit
      end
    end
  end

  def auto_like
    all_medias = medias
    id 			   = 0
    custom_puts '[+] '.cyan + "#{all_medias.size} Medias ready to like"

    until likes_in_day_are_full?
      begin
        get_media_informations(all_medias[id])
        custom_puts '[+] '.cyan + "Trying to like a media[#{all_medias[id]}]"
        like(@informations[:id])
        custom_puts "\n[+] ".cyan + 'Media liked'.green.bold
        @maximums[:likes_in_day] += 1
        id                       += 1
      rescue Exception => e
        puts "an error detected ... #{e}\n#{e.backtrace.inspect}\nignored"
        id += 1
        retry
      end
    end
  end

  def auto_comment
    all_medias = medias
    id 			   = 0
    custom_puts '[+] '.cyan + "#{all_medias.size} Medias ready to send a comment"

    until comments_in_day_are_full?
      begin
        get_media_informations(all_medias[id])
        id += 1 if @informations[:comments_disabled]
        custom_puts '[+] '.cyan + "Trying to send a comment to media[#{all_medias[id]}]"
        comment(@informations[:id], generate_a_comment)
        custom_puts "\n[+] ".cyan + 'comment successfully has been sent'.green.bold
        @maximums[:comments_in_day] += 1
        id                          += 1
        fall_in_asleep
      rescue Exception => e
        puts "an error detected ... #{e}\n#{e.backtrace.inspect}\nignored"
        id += 1
        retry
      end
    end
  end

  def generate_a_comment
    comments = options[:comments]
    first    = comments[0].sample
    second   = comments[1].sample
    third    = comments[2].sample
    fourth   = comments[3].sample
    fifth    = comments[4].sample
    "#{first} #{second} #{third} #{fourth}#{fifth}"
  end

  def check_date
    time = (@next_day - Time.new).to_i
    if time.zero?
      custom_print '[+] '.cyan + "It's a new day"
      @local_stroage[:followed_users]   = []
      @local_stroage[:unfollowed_users] = []
      @local_stroage[:liked_medias]     = []
      @local_stroage[:commented_medias] = []
      @maximums[:follows_in_day]        = 0
      @maximums[:unfollows_in_day]      = 0
      @maximums[:likes_in_day]          = 0
      @maximums[:comments_in_day]       = 0
      @next_day                         = Time.new + 1.days
      unless @infinite_tags == true
        search(options[:tags])
      end

    else
      custom_print '[+] '.cyan + "#{time} seconds remained"
    end
  end

  def fall_in_asleep
    time = options[:wait_per_action]
    custom_puts "\n[+] ".cyan + "Waiting for #{time} seconds"
    sleep time
  end

  def likes_in_day_are_full?
    @maximums[:likes_in_day] == @maximums[:max_likes_per_day]
  end

  def follows_in_day_are_full?
    @maximums[:follows_in_day] == @maximums[:max_follows_per_day]
  end

  def unfollows_in_day_are_full?
    @maximums[:unfollows_in_day] == @maximums[:max_unfollows_per_day]
  end

  def comments_in_day_are_full?
    @maximums[:comments_in_day] == @maximums[:max_comments_per_day]
  end

  def maximums_are_full?
    likes_in_day_are_full? && follows_in_day_are_full? &&
      unfollows_in_day_are_full? && comments_in_day_are_full?
  end
end
