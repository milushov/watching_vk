%w(sinatra git execjs pry open-uri awesome_print json).each(&method(:require))

set :dev, false
set :types, %w(js css)

set :root, File.dirname(__FILE__)
set :password, ENV['WATCHING_VK_PASSWORD']
set :state_file, "#{settings.root}/state.json"

set :js_file, 'http://vk.com/js/loader_nav0_0.js'
set :base, 'http://vk.me'
set :vk_files_path, '../watching_vk_files/'
set :paths, {
  '' => %w(mentions.js apps_flash.js map2.js map.css paginated_table.js paginated_table.css ui_controls.css touch.css),
  'lib' => %w(selects.js maps.js sort.js ui_controls.js),
  'api' => %w(oauth_popup.css oauth_page.css oauth_touch.css)
}

get '/' do
  'this page should contain some stats from db'
end

get '/dance_for_me/:password' do
  #redirect '/' unless settings.password == params['password']

  files = get_files
  last_state = get_last_state

  if last_state.empty?
    set_last_state files
    'last state is empty'
  else
    new_files = files.to_a - last_state.to_a

    if new_files.empty?
      'new files is empty'
    else
      set_last_state files
      #save_updates new_files
      save_to_git new_files

      new_files.to_s
    end
  end

end

helpers do
  def save_to_git new_files
    new_files.map! do |arr|
      file_name = arr.first
      base = settings.base
      type = settings.types.select{ |type| file_name.match(/\.(#{type})$/) }.first
      path = (paths = settings.paths.select{|_, files| files.include? file_name }).empty? ? 'al' : paths.keys.first
      File.join base, type, path, file_name
    end

    time = Time.now.strftime "%e.%m.%Y %-k:%M:%S"
    commit_message = "#{time} new files: #{new_files.count}"

    cd = "cd #{settings.vk_files_path}"
    wget = "wget -N #{new_files.join(' ')}"
    git = "git add . ; git commit -m '#{commit_message}'; git push origin master"

    status = system "#{cd}; #{wget}; #{git};"

    puts 'changes have been pushed to github!' if status
  end

  def get_files
    js_code = open(settings.js_file).read
    helper_js_function  = ' function getStVersions() { return stVersions };'
    context = ExecJS.compile(js_code + helper_js_function)
    files = context.call 'getStVersions'

    regex = /\.(#{ settings.types.join('|' ) })$/

    watching_files = {}; files.each do |file|
      name = file.first
      version = file.last

      if name.match regex
        watching_files[name] = version
      end
    end

    if settings.dev == true
      key = %w(mentions.js selects.js oauth_popup.css).sample
      val = rand 500..100500
      watching_files.merge!({key => val})
    end

    watching_files
  end

  def get_last_state
    if File.exist? settings.state_file
      file = File.open(settings.state_file).read.strip
      return JSON.parse file unless file.empty?
    end

    File.open(settings.state_file, 'w+') { |f| f.write '{}' }
    {}
  end

  def set_last_state hash
    File.open(settings.state_file, 'w+') { |f| f.write hash.to_json }
  end

  def save_updates new_files
    # TODO sql stuff
  end
end

