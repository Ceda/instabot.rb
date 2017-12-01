module Login
  def login(username = '', password = '')
    if @login_mode == :manual
      username = username.to_s
      password = password.to_s
    else
      username = options[:username]
      password = options[:password]
    end

    log('trying to login')
    custom_print '[+] '.cyan + "Trying to login into [#{username}] account"
    login_page         = @agent.get('https://www.instagram.com/accounts/login/?force_classic_login')
    page_form          = login_page.forms.last
    page_form.username = username
    page_form.password = password
    page               = page_form.submit

    if page.code == '200'
      @login_status = true
      log('successfully logged in')
      custom_print '[+] '.cyan + 'Successfully logged in'.green.bold
    else
      @login_status = false
      custom_print '[-] '.cyan + 'Invalid username or password or maybe a bug!'.red.bold
      exit
    end

    puts
  rescue Exception => e
    log("a error detected: #{e.class} #{e}")
    @login_status = false
    custom_print '[-] '.cyan + "#{e.class} #{e.message}".red
  end

  def logout
    log('trying to logout')
    custom_print '[+] '.cyan + 'Trying to logging out'
    set_mechanic_data
    @agent.get('https://www.instagram.com/accounts/logout/')
    @logout_status = true
    log('successfully logged out')
    custom_print '[+] '.cyan + 'Successfully logged out'
  end

  def check_login_status(mode = :default)
    log('checking loging status')
    if @login_status
      return true
    else
      custom_print '[-] '.cyan + "you're not logged in.".red.bold
      return false
      login if mode == :auto_retry # NEVER CALLED NEED FIX IT
    end
  end
end
