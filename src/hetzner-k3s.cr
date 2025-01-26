@[Link("ssh2", pkg_config: "libssh2")]
lib LibSSH2
end

require "admiral"
require "colorize"

require "./configuration/loader"
require "./k3s"
require "./cluster/create"
require "./cluster/delete"
require "./cluster/upgrade"

module Hetzner::K3s
  class CLI < Admiral::Command
    VERSION = "2.1.1.rc6"

    class Create < Admiral::Command
      define_help description: "create - Create a cluster"

      define_flag configuration_file_path : String,
                  description: "The path of the YAML configuration file",
                  long: "config",
                  short: "c",
                  required: true

      def run
        configuration = Configuration::Loader.new(flags.configuration_file_path, nil)
        configuration.validate(:create)

        Cluster::Create.new(configuration: configuration).run
      end
    end

    class Delete < Admiral::Command
      define_help description: "delete - Delete a cluster"

      define_flag configuration_file_path : String,
                  description: "The path of the YAML configuration file",
                  long: "config",
                  short: "c",
                  required: true

      def run
        configuration = Configuration::Loader.new(flags.configuration_file_path, nil)
        configuration.validate(:delete)

        Cluster::Delete.new(configuration: configuration).run
      end
    end

    class Upgrade < Admiral::Command
      define_help description: "upgrade - Upgrade a cluster to a newer version of k3s"

      define_flag configuration_file_path : String,
                  description: "The path of the YAML configuration file",
                  long: "config",
                  short: "c",
                  required: true

      define_flag new_k3s_version : String,
                  description: "The new version of k3s to upgrade to",
                  long: "--new-k3s-version",
                  required: true

      def run
        configuration = Configuration::Loader.new(flags.configuration_file_path, flags.new_k3s_version)
        configuration.validate(:upgrade)

        Cluster::Upgrade.new(configuration: configuration).run
      end
    end

    class Releases < Admiral::Command
      define_help description: "releases - List the available k3s releases"

      def run
        puts "Available k3s releases:"

        ::K3s.available_releases.each do |release|
          puts release
        end
      end
    end

    define_version VERSION

    define_help description: "hetzner-k3s - A tool to create k3s clusters on Hetzner Cloud"

    register_sub_command create : Create, description: "Create a cluster"
    register_sub_command delete : Delete, description: "Delete a cluster"
    register_sub_command upgrade : Upgrade, description: "Upgrade a cluster to a new version of k3s"
    register_sub_command releases : Releases, description: "List the available k3s releases"

    def run
      puts help
    end
  end
end

puts "_          _                            _    _____     ".colorize(:green)
puts "| |__   ___| |_ _____ __   ___ _ __     | | _|___ / ___ ".colorize(:green)
puts "| '_ \\ / _ \\ __|_  / '_ \\ / _ \\ '__|____| |/ / |_ \\/ __|".colorize(:green)
puts "| | | |  __/ |_ / /| | | |  __/ | |_____|   < ___) \\__ \\".colorize(:green)
puts "|_| |_|\\___|\\__/___|_| |_|\\___|_|       |_|\\_\\____/|___/".colorize(:green)
puts
puts "Version: #{Hetzner::K3s::CLI::VERSION}".colorize(:blue)
puts

Hetzner::K3s::CLI.run
