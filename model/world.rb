# frozen_string_literal: true

module Plugin::Mpc
  class World < Diva::Model
    register :mpc, name: "MPD"

    field.string :slug, required: true
    field.string :host, required: true
    field.int :port, required: true

    def initialize(**args)
      super(slug: "mpc_#{args[:host]}_#{args[:port]}", **args)
    end

    def user
      self
    end

    def name
      "#{host}#{port == 6600 ? '' : '#'+port} #{server_info || '(disconnected)'}"
    end
    alias_method :title, :name

    def icon
      Enumerator.new{ |y|
        Plugin.filtering(:photo_filter, 'https://4.bp.blogspot.com/-2UpYOZhygR0/UNbZx_3HHUI/AAAAAAAAJMU/VckQD2wAZAU/s1600/01_tone_kigou.png', y)
      }.first
    end

    def uri
      Diva::URI(port == 6600 ? "mpd://#{host}/" : "mpd://#{host}:#{port}/")
    end

    # MPDサーバにつないだ時に返ってくるバージョン情報文字列を返す。
    # "MPD 0.19.0" みたいな感じで
    def server_info
      @server_info ||= server_info_force
    end

    def server_info_force
      /^OK (.+)$/
        .match(
          TCPSocket
            .open(host, port)
            .each_line
            .find{|l| l.start_with?('OK ') } || ''
        )
        &.yield_self{|md| md[1] }
    rescue SocketError, Errno::ECONNREFUSED
      nil
    end
  end
end
