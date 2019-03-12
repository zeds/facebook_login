$(document).on('turbolinks:load', function() {
  console.log("It works on each visit!")

  /* Banner */
      $('body').addClass('banner_on').on('click', '#button_close_banner', function() {
        $('body').removeClass('banner_on');
      });
      agent = navigator.userAgent;
      if (agent.search(/iPhone/) !== -1 || agent.search(/iPad/) !== -1) {

        /* for iOS */
        // urlscheme = $('meta[property="al:ios:url"]').attr('slornuserapp://');
        urlscheme = "slornuserapp://"
        $('body').append('<div id="banner_app"><ul><li class="to_store"><a href="https://itunes.apple.com/jp/app/o-dena-kohi-kafe-jian-suo-slorn/id1103506104?mt=8" target="_blank">Slornアプリダウンロード</a></li><li class="open_app"><a href="' + urlscheme + '">アプリを開く</a></li></ul><a id="button_close_banner"><div id="button_close_banner_in"><span>閉じる</span></div></a></div>');
      } else if (agent.search(/Android/) !== -1) {

        /* for Android */
        // urlscheme = $('meta[property="al:android:url"]').attr('slornuserapp://');
        urlscheme = "slornuserapp://"
        $('body').append('<div id="banner_app"><ul><li class="to_store"><a href="https://play.google.com/store/apps/details?id=jp.tabletjapan.slorn.app.user" target="_blank">Slornアプリダウンロード</a></li><li class="open_app"><a href="' + urlscheme + '">アプリを開く</a></li></ul><a id="button_close_banner"><div id="button_close_banner_in"><span>閉じる</span></div></a></div>');
      } else {

        /* for PC */
        $('body').append('<div id="banner_app"><ul><li class="icon"><img src="https://slorn.jp/landingpage/img/icon_slorn.png"  width="160" height="160" alt="Slornアプリ"></li><li class="caption">アプリをダウンロードして<br>全ての機能を体験しよう！</li><li class="appstore"><a href="https://itunes.apple.com/jp/app/o-dena-kohi-kafe-jian-suo-slorn/id1103506104?mt=8" target="_blank"><img src="https://slorn.jp/landingpage/img/icon_appstore.png"  width="434" height="128" alt="App StoreでSlornアプリを見る"></a></li><li class="googleplay"><a href="https://play.google.com/store/apps/details?id=jp.tabletjapan.slorn.app.user" target="_blank"><img src="https://slorn.jp/landingpage/img/icon_googleplay.png"  width="440" height="128" alt="Google PlayでSlornアプリを見る"></a></li></ul><a id="button_close_banner"><div id="button_close_banner_in"><span>閉じる</span></div></a></div>');
      }

})
