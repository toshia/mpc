# frozen_string_literal: true

module Plugin::Mpc
  class Song < Diva::Model
    register :mpc_song, name: "MPD 楽曲"

    field.string :file, required: true
    field.time :last_modified, required: true
    field.int :track, required: true
    field.string :artist, required: true
    field.string :album_artist, required: true
    field.string :album, required: true
    field.string :title, required: true
    field.int :date, required: true
    field.int :time, required: true
    field.int :id, required: true

    # MPDからのレスポンスをパースする。
    # _response_ はレスポンスのString
    def self.parse(response)
      params = {}
      response.each_line do |l|
        camel_key, value = l.split(':', 2).map(&:strip)
        snake_key = camel_key
                      .gsub(/([a-z])([A-Z])/){|m| "#{m[1]}_#{m[2]}" }
                      .gsub(/\W/, '_')
                      .downcase.to_sym
        params[snake_key] = value
      end
      new(params)
    end
  end
end
