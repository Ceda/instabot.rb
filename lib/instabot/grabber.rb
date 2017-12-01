module Grabber
  def get_user_informations(user_id)
    begin
      user_page = "https://www.instagram.com/web/friendships/#{user_id}/follow/"
      response  = get_page(user_page)
      last_page = @agent.history.last.uri.to_s
      username  = last_page.split('/')[3]
      response  = @agent.get("https://instagram.com/#{username}/?__a=1")
    rescue Exception => e
      if response.code == '404'
        puts "ERORR: [404] Notfound\t#{e.message}".red
        exit!
      elsif response.code == '403'
        exit! if @error_403_times == 3
        @error_403_times += 1
        puts "ERROR: [403] (looks like you're banned from IG)".red
        retry
      end
    end

    data = JSON.parse(response.body)
    data.extend Hashie::Extensions::DeepFind

    @informations = {
      followers:   data.deep_find('followed_by')['count'],
      following:   data.deep_find('follows')['count'],
      is_private:  data.deep_find('is_private'),
      is_verified: data.deep_find('is_verified'),
      username:    data.deep_find('username'),
      full_name:   data.deep_find('full_name'),
      id:          data.deep_find('id')
    }
  end

  def get_media_informations(media_id)
    custom_puts '[+] '.cyan + "Trying to get media (#{media_id}) information"
    begin
      response	= @agent.get("https://www.instagram.com/p/#{media_id}/?__a=1")
    rescue Exception => e
      if response.code == '404'
        puts "ERORR: [404] Notfound\t#{e.message}".red
        exit!
      elsif response.code == '403'
        exit! if @error_403_times == 3
        @error_403_times += 1
        puts "ERROR: [403] (looks like you're banned from IG)".red
        retry
      end
    end

    data	= JSON.parse(response.body)
    data.extend Hashie::Extensions::DeepFind

    @informations = {
      id:                  data.deep_find('id'),
      is_video:            data.deep_find('is_video'),
      comments_disabled:   data.deep_find('comments_disabled'),
      viewer_has_liked:    data.deep_find('viewer_has_liked'),
      has_blocked_viewer:  data.deep_find('has_blocked_viewer'),
      followed_by_viewer:  data.deep_find('followed_by_viewer'),
      full_name:           data.deep_find('full_name'),
      is_private:          data.deep_find('is_private'),
      is_verified:         data.deep_find('is_verified'),
      requested_by_viewer: data.deep_find('requested_by_viewer'),
      text:                data.deep_find('text')
    }

    unless @infinite_tags == true
      tags = @informations[:text].encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').split(/\W+/)
      id  = 0
      tags.each do |tag|
        if tag == '_' || tag == '' || tag.nil?
          tags.delete(tag)
        else
          id += 1
          Config.options.tags << tag
        end
      end
      custom_puts "\n[+] ".cyan + '[' + id.to_s.yellow + '] New tags added'
    end
  end

  def search(tags = [])
    tags.each do |tag|
      url	= "https://www.instagram.com/explore/tags/#{tag}/?__a=1"
      custom_print '[+] '.cyan + "Searching in [##{tag}] tag"
      response = @agent.get(url)
      data     = JSON.parse(response.body)
      data.extend Hashie::Extensions::DeepFind
      owners      = data.deep_find_all('owner')
      media_codes = data.deep_find_all('code')
      owners.map { |id| users << id['id'] }
      media_codes.map { |code| medias << code }
      Config.options.tags.delete(tag)
    end

    custom_puts "\n[+] ".cyan + 'Total grabbed users [' + users.size.to_s.yellow + ']'
    custom_puts '[+] '.cyan + 'Total grabbed medias [' + medias.size.to_s.yellow + "]\n"
  end
end
