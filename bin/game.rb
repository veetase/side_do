require 'active_record'
require 'mysql2'
require 'open3'
yml_path = File.join(ENV['HOME'], '.side_do.rc.yaml')
raise "could not find your config file in #{yml_path}, please make it first" unless File.exist?(yml_path)

$config = YAML.load_file(yml_path)
ActiveRecord::Base.establish_connection(
  adapter:  $config[:adapter],
  host:     $config[:host],
  database: $config[:database],
  username: $config[:username],
  password: $config[:password]
)

class Game < ActiveRecord::Base
  has_many :game_files
end

class GameFile < ActiveRecord::Base
  STATUS_NEW         = 0
  STATUS_TO_VERIFY   = 1
  STATUS_VALIDATED   = 2
  STATUS_REJECTED    = 3
  STATUS_CANCELED    = 4
  STATUS_ROLLBACKED  = 5

  # Associations
  belongs_to :game
  scope :status_new, -> {where(status: STATUS_NEW)}
  scope :status_to_verify, -> {where(status: STATUS_TO_VERIFY)}
  scope :status_validated, -> {where(status: STATUS_VALIDATED)}

  def make_seed
    raise 'this game have not been preleased' if self.status != STATUS_NEW
    puts "-#{$config[:files_root_dir]}---- Start PreReleaseWorker"
    err = nil

    self.process_start_time = Time.now

    # release tool参数：<game_id, game_name, game_dir, patch_ver, release_dir, parent_id, parent_name, work_dir>
    game_id = self.game_id
    game = self.game
    game_name = game.dir_name
    parent_cmd = nil

    if game.parent_id && game.parent_id.to_i != 0
      parent_game = Game.find(game.parent_id)
      parent_cmd = "--parent_id=#{game.parent_id} --parent_name=\"#{parent_game.dir_name}\""
    end

    puts "Processing game #{game_id} - #{game.dir_name}..."
    release_tool_path = File.expand_path File.dirname(__FILE__) + '/DownloadReleaseTool.exe'
    cmd = "#{$config[:release_tool]} --game_id=#{game_id} --game_name=\"#{game_name}\" --game_dir=\"#{game_name}\" --patch_ver=#{self.patch_ver} --release_dir=\"#{self.file_dir}\" --work_dir=\"#{$config[:files_root_dir]}\" #{parent_cmd}"
    puts cmd
    output = ""
    stdin, stdoe = Open3.popen2e("#{cmd}")
    stdin.close

    while !stdoe.closed?
      line = stdoe.gets
      break unless line
      puts line
      output += line
    end

    stdoe.close unless stdoe.closed?

    msg = JSON.parse(output)
    release_ret = msg["result"]
    release_digest = msg["digest"]
    err_ret = msg["err"]

    if release_ret
      puts "Game seed successfully made..."
      puts "verifying the digest..."
      seed_content_path = nil
      if self.file_dir == "initial"
        seed_content_path = $config[:file_meta_dir] + "/#{game.dir_name}.mf"
      else
        seed_content_path = $config[:file_meta_dir] + "/#{game.dir_name}_patch_#{self.patch_ver}.mf"
      end

      seed_content = nil
      File.open(seed_content_path, "rb"){|s| seed_content = s.read}

      file_size = msg["size"]
      real_digest = Digest::SHA1.hexdigest(seed_content)

      if release_digest == real_digest
        ActiveRecord::Base.transaction do
          self.seed_content = seed_content
          self.seed_digest = real_digest
          self.file_size = file_size
          self.process_finish_time = Time.now
          self.status = STATUS_TO_VERIFY
          self.save!
        end
        puts "Success!"
      else
        err = "Failed, digest is not match."
        raise err
      end
    else
      err = err_ret || output
      raise err
    end
  end
end