# -*- coding: utf-8 -*-

require_relative 'model/world'
require_relative 'model/song'

Plugin.create(:mpc) do
  defspell(:compose, :mpc,
           condition: ->(mpc){
             true
           }) do |mpc, body: nil|
    mpc.request(body).next { |x|
      notice x
      activity :system, x
      x
    }.trap{|x|
      error x
      activity :error, x
      x
    }
  end

  defspell(:playing_song, :mpc,
           condition: ->(mpc){ true }
          ) do |mpc|
    mpc.playing_song
  end


  command(:mpc_post_current_song,
          name: 'MPDで再生中の楽曲のタイトルを貼り付け',
          condition: ->opt{
            world, = Plugin.filtering(:world_current, nil)
            playing_song?(world)
          },
          visible: true,
          role: :postbox) do |opt|
    world, = Plugin.filtering(:world_current, nil)
    playing_song(world).next do |song|
      postbox = Plugin::GUI::Postbox.instance
      postbox.options = {footer: "Now Playing #{song.title}", delegate_other: false}
      Plugin::GUI::Window.instance(:default) << postbox
    end
  end

  world_setting(:mpc, 'MPC') do
    self[:host] = 'localhost'
    self[:port] = 6600
    label 'MPDサーバの情報を入力してください'
    input 'host', :host
    adjustment 'port', :port, 0, 65535
    mpd = Plugin::Mpc::World.new(await_input.to_h)
    info = mpd.server_info
    if info
      label 'このサーバを登録しますか？'
      label info
      mpd
    else
      Deferred.next{ Deferred.fail('サーバに接続できませんでした') }
    end
  end
end

