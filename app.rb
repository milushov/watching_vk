%w(sinatra git execjs pry open-uri awesome_print json).each(&method(:require))

set :dev, true
set :types, %w( js css )

set :root, File.dirname(__FILE__)
set :password, ENV['WATCHING_FILES_APP_PASSWORD']
set :state_file, "#{settings.root}/state.json"

set :js_file, 'http://vk.com/js/loader_nav0_0.js'
set :js_base, 'http://vk.me/js/al/'
set :css_base, 'http://vk.me/css/al/'
set :vk_files_path, './files'

get '/' do
  'this page should contain some stats from db'
end

get '/dance_for_me/:password' do
  #redirect '/' unless settings.password == params['password']

  files = get_files
  last_state = get_last_state

  unless last_state.empty?
    #binding.pry
    new_files = files.to_a - last_state.to_a

    unless new_files.empty?
      set_last_state files
      #save_updates new_files
      save_to_git new_files
      new_files.to_s
    else
      'new_files is empty'
    end
  else
    set_last_state files
    'nope'
  end

end

helpers do
  def save_to_git new_files
    new_files.map! do |arr|
      file_name = arr.first
      type = settings.types.select{ |type| file_name.match(/\.(#{type})$/) }.first
      base = settings.send "#{type}_base".to_sym
      base + file_name
    end

    system "wget -P #{settings.vk_files_path} #{new_files.join(' ')}"
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

    watching_files.merge!({'common.js' => 100500}) if settings.dev == true

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

