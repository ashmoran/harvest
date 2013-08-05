# Copied from: https://github.com/guard/guard-process/blob/a6b50dc05f0d3b94e1d10a8fd1ede8574ad096e6/lib/guard/process.rb
# I duplicated the file as the project is touched so infrequently it's
# dragging in alarmingly old dependencies (eg ffi)

# Guard 1.0.6 or later will probably include a fix to remove this dependency
# (it's in the GitHub repo)

require 'guard'
require 'guard/guard'
require 'spoon'

module Guard
  class Process < Guard
    def initialize(watchers = [], options = {})
      @pid = nil
      @command = options.fetch(:command).split(" ")
      @env = options[:env] || {}
      @name = options[:name]
      @stop_signal = options[:stop_signal] || "TERM"
      super
    end

    def process_running?
      begin
        @pid ? ::Process.kill(0, @pid) : false
      rescue Errno::ESRCH => e
        false
      end
    end

    def start
      UI.info("Starting process #{@name}")
      original_env = {}
      @env.each_pair do |key, value|
        original_env[key] = ENV[key]
        ENV[key] = value
      end
      @pid = Spoon.spawnp(*@command)
      original_env.each_pair do |key, value|
        ENV[key] = value
      end
      UI.info("Started process #{@name}")
    end

    def stop
      if @pid
        UI.info("Stopping process #{@name}")
        ::Process.kill(@stop_signal, @pid)
        ::Process.waitpid(@pid) rescue Errno::ESRCH
        @pid = nil
        UI.info("Stopped process #{@name}")
      end
    end

    def reload
      stop
      start
    end

    def run_all
      true
    end

    def run_on_change(paths)
      reload
    end
  end
end