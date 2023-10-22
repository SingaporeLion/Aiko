import 'dart:async';
import '/helper/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/helper/notification_helper.dart';
import '/model/chat_model/chat_model.dart';
import '/model/user_model/user_model.dart';
import '/utils/strings.dart';
import '/services/api_services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class ChatController extends GetxController {

  // Hier fügen Sie die neuen Instanzvariablen ein
  String userName = '';
  int userAge = 0;
  String userGender = '';

  List<String> schimpfwoerter = [
    "doof",
    "dumm",
    "blöd",
    "idiot",
    "trottel",
    "nervensäge",
    "heini",
    "schussel",
    "fettsack",
    "schwanzkind",
    "fotze",
    "dussel",
    "depp",
    "wichser",
    "wixxer",
    "fuck",
    "fuck you",
    "arschloch",
    "schlampe",
    "mistkerl",
    "penner",
    "spasti",
    "spassti",
    "spast",
    "hure",
    "pisser",
    "saukerl",
    "schnepfe",
    "tussi",
    "vollpfosten",
    "vollidiot",
    "lappen",
    "looser",
    "opfer",
    "pfeife",
    "stinktier",
    "zicke",
    "fotze",
    "wichser",
    "bastard",
    "lügner",
    "versager",
    "niete",
    "stinktier",
    "affe",
    "schwein",
    "ratte",
    "miststück",
    "pfeife",
    "nulpe",
    "hackfresse",
    "vögeln",
    "fögeln",
    "dussel",
    "flachzange",
    "hohlkopf",
    "knallkopf",
    "lappen",
    "loser",
    "looser",
    "mistsau",
    "möchtegern",
    "nase",
    "pflaume",
    "sackratte",
    "schwachmat",
    "tölpel",
    "vollpfosten",
    "warmduscher",
    "weichei",
    "witzfigur",
    "zimtzicke",
    "dödel",
    "honk",
    "kasper",
    "lurch",
    "opfer",
    "pissnelke",
    "schnarchnase",
    "tucke",
    "tunte",
    "vollhorst",
    "labertasche",
    "quatschkopf",
    "schwätzer",
    "schwuler",
    "schwuchtel",
    "tratschtante",
    "dampfplauderer",
    "ficken",
    "fick dich",
    "vicken",
    "vick dich",

    // ... Sie können diese Liste nach Bedarf erweitern
  ];

  final String chatGPTAPIURL = 'https://api.openai.com/v1/chat/completions';
  final String googleSearchAPIURL = 'https://www.googleapis.com/customsearch/v1?key=YOUR_API_KEY&cx=96f7a0294adec4a92&q=YOUR_SEARCH_QUERY';
  final String googleAPIKey = 'AIzaSyAU3J4y31RKcY7cCkXagS9OoLk1WUiv5yU';
  final String googleSearchEngineID = '96f7a0294adec4a92';

  Future<String> askChatGPT(String userMessage) async {
    var url = Uri.parse(chatGPTAPIURL);  // Die URL zur OpenAI API
    var body = {
      "model": "gpt-3.5-turbo",
      "messages": [{"role": "user", "content": userMessage}]
    };
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer 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"  // Ersetzen Sie dies durch Ihren tatsächlichen API-Schlüssel
    };
    var response = await http.post(url, body: json.encode(body), headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['choices'][0]['message']['content'];
    } else {
      throw Exception('Oops! Ich habe gerade ein kleines Problem. Kannst du es später noch einmal versuchen?');
    }
  }

  Future<List<String>> searchGoogle(String query) async {
    final String apiKey = 'AIzaSyAU3J4y31RKcY7cCkXagS9OoLk1WUiv5yU';
    final String searchEngineId = '96f7a0294adec4a92';
    final String endpoint = 'https://www.googleapis.com/customsearch/v1?q=$query&key=$apiKey&cx=$searchEngineId';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var items = data['items'] as List;
      List<String> links = [];

      for (var item in items) {
        String link = item['link'];
        links.add(link);  // Fügen Sie den Link zur Liste hinzu

        // Überprüfen Sie die Blacklist
        if (blacklist.any((blacklistedUrl) => link.contains(blacklistedUrl))) {
          print(_getRandomChildFriendlyMessage());
          return [];  // Rückgabe einer leeren Liste
        }

// Überprüfen Sie die Whitelist
        if (!whitelist.any((whitelistedUrl) => link.contains(whitelistedUrl))) {
          print(_getRandomChildFriendlyMessage());
          continue;  // Überspringen Sie diese URL und gehen Sie zur nächsten
        }

        print(item['title']);
        print(link);
        print('---');
      }
      return links;  // Rückgabe der Linkliste
    } else {
      print('Oh nein! Ich konnte die Suchergebnisse nicht laden. Lass es uns später noch einmal versuchen. 🌈');
      return [];
    }
  }


  Future<bool> isSchimpfwort(String word) async {
    // Fragen Sie die KI, ob das Wort ein Schimpfwort ist
    // Dies ist nur ein Pseudocode, Sie müssten die tatsächliche Implementierung an Ihre Umgebung anpassen
    String response = await askChatGPT("Ist '$word' ein Schimpfwort?");
    return response.contains("Ja");  // Oder eine andere Logik, um die Antwort zu interpretieren
  }

  void handleChatInput(String query) async {
    for (String word in query.split(" ")) {
      if (schimpfwoerter.contains(word.toLowerCase()) || await isSchimpfwort(word)) {
        print("Ich habe ein Wort bemerkt, das manchmal als unhöflich angesehen wird. Kannst du mir mehr darüber erzählen, warum du es verwendet hast?");
        return;
      }
    }
    // Wenn kein Schimpfwort gefunden wurde, fragen Sie ChatGPT
    String chatGPTResponse = await askChatGPT(query);
    print(chatGPTResponse);  // Zeigt die Antwort von ChatGPT an
  }




  // Blacklist von URLs
  List<String> blacklist = [
    // Erwachseneninhalte
    "playboy.com",
    "penthouse.com",
    "xvideos.com",
    "xnxx.com",
    "pornhub.com",
    "youporn.com",
    "redtube.com",

    // Glücksspiel
    "bet365.com",
    "pokerstars.com",
    "unibet.com",
    "bwin.com",
    "ladbrokes.com",

    // Drogen und Alkohol
    "absolut.com",
    "leafly.com",
    "highsnobiety.com",
    "cannabis.info",
    "beeradvocate.com",

    // Gewalt und Waffen
    "gunsamerica.com",
    "coldsteel.com",
    "gunbroker.com",
    "cheaperthandirt.com",

    // Tabak und Zigaretten
    "marlboro.com",
    "camel.com",
    "vusevapor.com",

    // Andere potenziell ungeeignete Inhalte
    "4chan.org",
    "liveleak.com",
    "bestgore.com",
    "rotten.com",

    // ... (Ihre bisherige Liste)
    'www.hackerforum.net',
    'www.exploitsdatabase.com',
    'www.hacktoolshop.com',
    'www.torproject.org',
    'www.hiddenwiki.com',
    // ... (Ihre bisherige Liste)
    'www.4chan.org',
    'www.8chan.net',
    'www.hackforums.net',
    'www.deepdotweb.com',
    'www.dreammarket.com',
    'www.alpha-bay.com',
    'www.silkroad.com',
    'www.firechallenge.com',
    'www.tidepodchallenge.com',
    // ... (Ihre bisherige Liste)
    'www.xnxx.com',
    'www.youporn.com',
    'www.x-art.com',
    'www.coupe24.de',
    'www.livejasmin.com',
    'www.g.e-hentai.org',
    'www.adultfriendfinder.com',
    'www.cam4.com',
    'www.nudevista.com',
    'www.flirt4free.com',
    'www.xcams.com',
    'www.fetlife.com',
    'www.adam4adam.com',
    'www.literotica.com',
    'www.ebaumsworld.com',
    'www.freeones.com',
    'www.playboy.com',
    'www.playboy.de',
    'www.planetsuzy.org',
    'www.manhunt.net',
    'www.imlive.com',
    'www.furaffinity.net',
    'www.newgrounds.com',
    'www.digitalplayground.com',
    'www.pururin.com',
    'www.payserve.com',
    'www.asexstories.com',
    'www.clips4sale.com',
    'www.fakku.net',
    'www.mrskin.com',
    'www.nhentai.net',
    'www.oglaf.com',
    'www.streamate.com',
    'www.asstr.org',
    'www.shooshtime.com',
    'www.fling.com',
    'www.aebn.net',
    'www.thehun.net',
    'www.iafd.com',
    'www.squirt.org',
    'www.cams.com',
    'www.voyeurweb.com',
    'www.aventertainments.com',
    'www.hentai-foundry.com',
    'www.worldsex.com',
    'www.videosexarchive.com',
    'www.girlfriendvideos.com',
    'www.nifty.org',
    'www.celebritymoviearchive.com',
    'www.femjoy.com',
    'www.fabswingers.com',
    'www.scoreland.com',
    'www.luscious.net',
    'www.adultdvdempire.com',
    'www.ftvgirls.com',
    'www.adameve.com',
    'www.indiansexstories.net',
    'www.vintage-erotica-forum.com',
    'www.recon.com',
    'www.swinglifestyle.com',
    'www.suicidegirls.com',
    'www.somethingpositive.net',
    'www.private.com',
    'www.videobox.com',
    'www.dudesnude.com',
    'www.peachyforum.com',
    'www.f-list.net',
    'www.lovehoney.co.uk',
    'www.tonybatman.com',
    'www.adultdvdtalk.com',
    'www.www74.virtuagirl.com',
    'www.debonairblog.com/blog/',
    'www.joerogan.net',
    'www.wickedweasel.com',
    'www.sdc.com',
    'www.1999.co.jp/eng/',
    'www.mplstudios.com',
    'www.odloty.pl',
    'www.hustler.com',
    'www.rentboy.com',
    'www.gamelink.com',
    'www.sunnyleone.com',
    'www.onlydudes.com',
    'www.penthouse.com',
    'www.jlist.com',
    'www.niteflirt.com',
    'www.goaskalice.columbia.edu',
    'www.https://inkbunny.net/',
    'www.fleshlight.com',
    'www.southern-charms.com',
    'www.lushstories.com',
    'www.hentairules.net',
    'www.sucksex.com',
    'www.rabbitsreviews.com',
    'www.biggercity.com',
    'www.mcstories.com',
    'www.teendreams.com',
    'www.gaydemon.com',
    'www.wtfpeople.com',
    'www.cityvibe.com',
    'www.escort-ireland.com',
    'www.manjam.com',
    'www.annsummers.com',
    'www.killsometime.com',
    'www.alsscan.com',
    'www.1by-day.com',
    'www.fuckingmachines.com',
    'www.xbiz.com',
    'www.drago99.com',
    'www.buttsmithy.com',
    'www.clublez.com/movies/',
    'www.bestvibes.ca',
    'www.kinseyinstitute.org',
    'www.lustomic.com',
    'www.jadedvideo.com',
    'www.rottencotton.com',
    'www.restrainedelegance.com',
    'www.superheroinecentral.com',
    'www.sybian.com',
    'www.landofvenus.com',
    'www.allasiandvd.com',
    'www.clubsandy.com',
    'www.slavefarm.com',
    'www.drawn-hentai.com',
    'www.asubmissivesjourney.com',
    'www.eugeniadiordiychuk.com',
    'www.kamasutra.com',
    'www.linseysworld.com',
    'www.bulldoglist.com',
    'www.ebanned.net',
    'www.thelbb.co.uk',
    'www.cumm.co.uk',
    'www.hunterscash.com',
    'www.houseofgord.com',
    'www.stripclublist.com',
    'www.secretfriends.com',
    'www.clublez.com/movies/',
    'www.bestvibes.ca',
    'www.kinseyinstitute.org',
    'www.lustomic.com',
    'www.jadedvideo.com',
    'www.rottencotton.com',
    'www.restrainedelegance.com',
    'www.superheroinecentral.com',
    'www.sybian.com',
    'www.landofvenus.com',
    'www.allasiandvd.com',
    'www.clubsandy.com',
    'www.slavefarm.com',
    'www.drawn-hentai.com',
    'www.asubmissivesjourney.com',
    'www.eugeniadiordiychuk.com',
    'www.kamasutra.com',
    'www.linseysworld.com',
    'www.bulldoglist.com',
    'www.ebanned.net',
    'www.thelbb.co.uk',
    'www.cumm.co.uk',
    'www.hunterscash.com',
    'www.houseofgord.com',
    'www.stripclublist.com',
    'www.secretfriends.com',
    'www.clublez.com/movies/',
    'www.bestvibes.ca',
    'www.kinseyinstitute.org',
    'www.lustomic.com',
    'www.jadedvideo.com',
    'www.rottencotton.com',
    'www.restrainedelegance.com',
    'www.superheroinecentral.com',
    'www.sybian.com',
    'www.landofvenus.com',
    'www.allasiandvd.com',
    'www.clubsandy.com',
    'www.slavefarm.com',
    'www.drawn-hentai.com',
    'www.asubmissivesjourney.com',
    'www.eugeniadiordiychuk.com',
    'www.kamasutra.com',
    'www.linseysworld.com',
    'www.bulldoglist.com',
    'www.ebanned.net',
    'www.thelbb.co.uk',
    'www.cumm.co.uk',
    'www.hunterscash.com',
    'www.houseofgord.com',
    'www.stripclublist.com',
    'www.secretfriends.com'
        'www.earlmiller.com',
    'www.the-clitoris.com',
    'www.almightyzeus.com',
    'www.prettybigescorts.com',
    'www.spankingblog.com',
    'www.sandyssuperstars.com',
    'www.isna.org',
    'www.thespankinglibrary.org',
    'www.tommys-bookmarks.com',
    'www.wasteland.com',
    'www.drunkcyclist.com',
    'www.sinfulcelebs.freesexycomics.com',
    'www.hentai-top100.com',
    'www.nakedworld.com',
    'www.saafe.info',
    'www.famous-comics.com',
    'www.escortmadeira.com',
    'www.cherrygirls.co.uk',
    'www.smutnetwork.com',
    'www.fisting.com',
    'www.smokingsides.com',
    'www.lovehentaimanga.com',
    'www.drivenbyboredom.com',
    'www.webyoung.com',
    'www.pornhome.com',
    'www.mistressalexia.com',
    'www.erotic4u.com',
    'www.sexylosers.com',
    'www.bachelorettepartyfun.com',
    'www.taratainton.com',
    'www.symtoys.com',
    'www.fetters.co.uk',
    'www.lucaskazan.com',
    'www.mymasturbation.com',
    'www.tram-pararam.com',
    'www.webmastercentral.com',
    'www.theredzone.com',
    'www.dollstory.eu',
    'www.britishsexcontacts.com',
    'www.adisc.org/forum/',
    'www.webmasters.asiamoviepass.com',
    'www.bigdoggie.net',
    'www.smittenkittenonline.com',
    'www.pissblog.com/blog/',
    'www.bgeast.com',
    'www.writingsofleviticus.thekinkyserver.com',
    'www.australian-babe.com',
    'www.sex-techniques-and-positions.com',
    'www.tgp.89.com',
    'www.babes6.com',
    'www.adultwork.co.uk',
    'www.real-femdom.com',
    'www.tantrachair.com',
    'www.flashcash.com',
    'www.https://www.sextoys247.net.au/',
    'www.publicflash.com',
    'www.simonscans.com',
    'www.transladyboy.com',
    'www.ilove-movies.com/main.html',
    'www.glamourboutique.com',
    'www.spacash.com',
    'www.videoboys.com',
    'www.ourdollcommunity.com',
    'www.brutalasia.com',
    'www.acemassage.net',
    'www.booklocker.com',
    'www.just18.com',
    'www.shemalestrokers.com',
    'www.awal.com',
    'www.dcup.com',
    'www.japanhardcoremovies.com',
    'www.cb-x.com',
    'www.cavr.com',
    'www.straightfellas.com',
    'www.photo-personals.co.uk',
    'www.archive.xusenet.com/home.html',
    'www.blacklabelsextoys.com.au',
    'www.altplayground.net',
    'www.dollmate.jp',
    'www.sxvideo.com/index.html',
    'www.cdgirls.com',
    'www.boundstories.net/bdstories.html',
    'www.lovercash.com',
    'www.daddyswap.com',
    'www.naughtyallie.com',
    'www.cartoonvalley.com',
    'www.nextdoormale.com',
    'www.medicaltoys.com',
    'www.hush-hush.co.uk',
    'www.homemade-sex-toys.com',
    'www.desire.originalresorts.com',
    'www.personalcams.com',
    'www.demask.com',
    'www.https://www.orient-doll.com/',
    'www.cndb.com',
    'www.tthfanfic.org',
    'www.menonthenet.com/eroticstories/',
    'www.furriesxtreme.org',
    'www.bigmuscle.com',
    'www.exmasters.com',
    'www.tinynibbles.com',
    'www.carolcox.com',
    'www.wb270.com',
    'www.iseekgirls.com',
    'www.peternorth.com',
    'www.x-screensaver.com',
    'www.priape.com',
    'www.misterb.com',
    'www.thatmall.com',
    'www.richards-realm.com',
    'www.mensize.com',
    'www.asianzilla.com',
    'www.jbvideo.com',
    'www.realspankings.com',
    'www.jackinchat.com',
    'www.darkwanderer.net',
    'www.freegaypix.com',
    'www.peteristhewolf.com',
    'www.nude-in-public.com',
    'www.orgymania.net',
    'www.suze.net',
    'www.northernangels.co.uk',
    'www.bigbreastarchive.com',
    'www.hqpornlinks.com',
    'www.sexyasian18.com',
    'www.adultlabs.com',
    'www.christiesroom.com',
    'www.short-fiction.co.uk',
    'www.smutjunkies.com',
    'www.escortstoplist.com',
    'www.black-tgirls.com',
    'www.auxxxreviews.com',
    'www.angelsoflondon.com',
    'www.adultshop.com.au',
    'www.sexualhealth.com',
    'www.elite-forum.org',
    'www.newzealandgirls.co.nz',
    'www.pornusers.com',
    'www.escort.cz',
    'www.1on1wholesale.co.uk',
    'www.cutepet.org',
    'www.divaescort.com',
    'www.tgirls.com',
    'www.porn365.com',
    'www.eroticillusions.com',
    'www.lyla.com',
    'www.terapatrick.com',
    'www.fetishhits.com',
    'www.sextoys.co.uk',
    'www.utoyiastories.com/stories',
    'www.femdomcity.com',
    'www.transformation.co.uk',
    'www.danni.com',
    'www.ladirectmodels.com',
    'www.fantasies.com',
    'www.pavelphoto.com',
    'www.bulldoglist.com',
    'www.wickedtemptations.com',
    'www.babeland.com',
    'www.burningangel.com',
    'www.kellymadison.com',
    'www.ynot.com',
    'www.https://www.orient-doll.com/',
    'www.cndb.com',
    'www.tthfanfic.org',
    'www.swingtowns.com',
    'www.milovana.com',
    'www.jabcomix.com',
    'www.intothelifestyle.com',
    'www.dofantasy.com',
    'www.realdoll.com',
    'www.javmodel.com',
    'www.asianthumbs.org',
    'www.hothouse.com',
    'www.allinternal.com',
    'www.lingeriediva.com',
    'www.asstraffic.com',
    'www.eroticstories.com',
    'www.latinboyz.com',
    'www.selectanescort.com',
    'www.sugardvd.com',
    'www.sexycaracas.com',
    'www.intensecash.com',
    'www.williamhiggins.com',
    'www.sexacartoon.com',
    'www.xrentdvd.com',
    'www.persiankitty.com',
    'www.myfirsttime.com',
    'www.2adultflashgames.com',
    'www.sapphicerotica.com',
    'www.meo.de',
    'www.stripperweb.com',
    'www.datinggold.com',
    'www.kaktuz.com',
    'www.adultspace.com',
    'www.extasycams.com',
    'www.statsremote.com',
    'www.3d-sexgames.com',
    'www.divascam.com',
    'www.thumbnailseries.com',
    'www.sexuality.about.com',
    'www.scottss.com',
    'www.actionjav.com',
    'www.chubbyparade.com/forum/',
    'www.femalefirst.co.uk/board/',
    'www.mycuteasian.com',
    'www.spicymatch.com',
    'www.jastusa.com',
    'www.crazyxxx3dworld.com',
    'www.kristenbjorn.com',
    'www.clickcash.com',
    'www.honour.co.uk',
    'www.local-swingers.co.uk',
    'www.fantasyfeeder.com',
    'www.cruisingforsex.com',
    'www.dollforum.com',
    'www.sexforums.com',
    'www.mr-s-leather.com',
    'www.eveknows.com',
    'www.19nitten.com/free/',
    'www.adultshopping.com.au',
    'www.sexintheuk.com',
    'www.moreystudio.com',
    'www.sexyjobs.com',
    'www.sexinart.net',
    'www.celebnakedness.com',
    'www.freesexycomics.com',
    'www.hush-hush.com',
    'www.myfriendsfeet.com',
    'www.badpuppy.com',
    'www.popporn.com',
    'www.naughtybids.com',
    'www.occash.com',
    'www.eurorevenue.com',
    'www.menonthenet.com',
    'www.nudeafrica.com',
    'www.sexstoriespost.com',
    'www.worldsexguide.com',
    'www.ultimate-fetishes.com',
    'www.ronharris.com',
    'www.kanojotoys.com',
    'www.thevalkyrie.com',
    'www.nicennaughty.co.uk',
    'www.mikesouth.com',
    'www.jbvideo.com',
    'www.realspankings.com',
    'www.jackinchat.com',
    'www.darkwanderer.net',
    'www.freegaypix.com',
    'www.peteristhewolf.com',
    'www.nude-in-public.com',
    'www.orgymania.net',
    'www.suze.net',
    'www.northernangels.co.uk',
    'www.bigbreastarchive.com',
    'www.hqpornlinks.com',
    'www.sexyasian18.com',
    'www.adultlabs.com',
    'www.christiesroom.com',
    'www.short-fiction.co.uk',
    'www.smutjunkies.com',
    'www.escortstoplist.com',
    'www.black-tgirls.com',
    'www.auxxxreviews.com',
    'www.angelsoflondon.com',
    'www.adultshop.com.au',
    'www.sexualhealth.com',
    'www.elite-forum.org',
    'www.newzealandgirls.co.nz',
    'www.pornusers.com',
    'www.escort.cz',
    'www.1on1wholesale.co.uk',
    'www.cutepet.org',
    'www.divaescort.com',
    'www.tgirls.com',
    'www.porn365.com',
    'www.eroticillusions.com',
    'www.lyla.com',
    'www.terapatrick.com',
    'www.fetishhits.com',
    'www.sextoys.co.uk',
    'www.utoyiastories.com/stories',
    'www.femdomcity.com',
    'www.transformation.co.uk',
    'www.danni.com',
    'www.ladirectmodels.com',
    'www.fantasies.com',
    'www.pavelphoto.com',
    'www.bulldoglist.com',
    'www.wickedtemptations.com',
    'www.babeland.com',
    'www.burningangel.com',
    'www.kellymadison.com',
    'www.ynot.com',
    'www.https://www.orient-doll.com/',
    'www.cndb.com',
    'www.tthfanfic.org',
    'www.swingtowns.com',
    'www.milovana.com',
    'www.hackerforum.net',
    'www.exploitsdatabase.com',
    'www.hacktoolshop.com',
    'www.torproject.org',
    'www.hiddenwiki.com',
    'www.hackthissite.org',
    'www.0day.today',
    'www.deepdotweb.com',
    'www.dreammarket.com',
    'www.silkroad.com',
    'www.bluewhalechallenge.com',
    'www.tidepodchallenge.com',
    'www.facebook.com',
    'www.twitter.com',
    'www.tiktok.com',
    'www.instagram.com',
    'www.snapchat.com',
    'www.linkedin.com',
    'www.pinterest.com',
    'www.reddit.com',
    'www.youtube.com',
    'www.whatsapp.com',
    'www.messenger.com',
    'www.viber.com',
    'www.telegram.org',
    'www.wechat.com',
    'www.line.me',
    'www.tumblr.com',
    'www.vk.com',
    'www.flickr.com',
    'www.meetup.com',
    'www.tagged.com',
    'www.ask.fm',
    'www.meetme.com',
    'www.classmates.com',
    'www.hi5.com',
    'www.myspace.com',
    'www.periscope.tv',
    'www.vine.co',
    'www.habbo.com',
    'www.badoo.com',
    'www.kik.com',
    'www.weheartit.com',
    'www.friendster.com',
    'www.flixster.com',
    'www.goodreads.com',
    'www.twitch.tv',
    'www.mixer.com',
    'www.dlive.tv',
    'www.discordapp.com',
    'www.slack.com',
    'www.teams.microsoft.com',
    'www.zoom.us',
    'www.skype.com',
    'www.trello.com',
    'www.asana.com',
    'www.jira.atlassian.com',
    'www.gitlab.com',
    'www.github.com',
    'www.bitbucket.org',
    'www.dropbox.com',
    'www.google.com/drive/',
    'www.onedrive.live.com',
    'www.box.com',
    'www.apple.com/icloud/',
    'www.amazon.com/clouddrive/',
    'www.sugarsync.com',
    'www.mega.nz',
    'www.adrive.com',
    'www.mediafire.com',
    'www.4shared.com',
    'www.zoho.com/docs/',
    'www.godaddy.com',
    'www.namecheap.com',
    'www.bluehost.com',
    'www.hostgator.com',
    'www.dreamhost.com',
    'www.siteground.com',
    'www.a2hosting.com',
    'www.inmotionhosting.com',
    'www.wix.com',
    'www.weebly.com',
    'www.squarespace.com',
    'www.shopify.com',
    'www.bigcommerce.com',
    'www.magento.com',
    'www.volusion.com',
    'www.prestashop.com',
    'www.3dcart.com',
    'www.mojoportal.com',
    'www.drupal.org',
    'www.joomla.org',
    'www.wordpress.org',
    'www.blogger.com',
    'www.typed.com',
    'www.ghost.org',
    'www.medium.com',
    'www.svbtle.com',
    'www.postach.io',
    'www.anchor.fm',
    'www.soundcloud.com',
    'www.podbean.com',
    'www.buzzsprout.com',
    'www.transistor.fm',
    'www.simplecast.com',
    'www.castos.com',
    'www.podomatic.com',
    'www.spreaker.com',
    'www.acast.com',
    'www.podcastwebsites.com',
    'www.zencast.fm',
    'www.libsyn.com',
    'www.blubrry.com',
    'www.podiant.co',
    'www.backtracks.fm',
    'www.pinecast.com',
    'www.redcircle.com',
    'www.podserve.fm',
    'www.whooshkaa.com',
    'www.podcastics.com',
    'www.podigee.com',
    'www.omnystudio.com',
    'www.megaphone.fm',
    'www.audioboom.com',
    'www.captivate.fm',
    'www.fireside.fm',
    'www.getawesound.com',
    'www.pippa.io',


    // ... fügen Sie hier weitere URLs hinzu
  ];


  List<String> whitelist = [
    'www.kika.de',
    'www.toggo.de',
    'www.disney.de',
    'www.nick.de',
    'www.junior.tv',
    'www.kinderfilmwelt.de',
    'www.kinderbuch-couch.de',
    'www.kidsweb.de',
    'www.blinde-kuh.de',
    'www.kinderzeitmaschine.de',
    'www.kinderkino.de',
    'www.kinderfilme.de',
    'www.lesen.de/books/kinder-jugendbuecher/',
    'www.kids-tv.de',
    'www.kinderundjugendmedien.de',
    'www.kinderfilm-online.de',
    'www.kidsville.de',
    'www.kindermedien.de',
    'www.stiftunglesen.de',
    'www.buecherkinder.de',
    'www.legakids.net',
    'www.kinderbuchlesen.de',
    'www.kinderfilmuniversum.de',
    'www.kidsweb.de',
    'www.kinderfilmwelt.de',
    'www.kinderbuch-couch.de',
    'www.kids-tv.de',
    'www.kinderundjugendmedien.de',
    'www.kinderfilm-online.de',
    'www.kinderfilme.de',
    'www.lesen.de/books/kinder-jugendbuecher/',
    'www.kidsville.de',
    'www.kindermedien.de',
    'www.stiftunglesen.de',
    'www.buecherkinder.de',
    'www.legakids.net',
    'www.kinderbuchlesen.de',
    'www.kinderfilmuniversum.de',
    'www.youtubekids.com',  // YouTube Kids hinzugefügt
  ];


  String _getRandomChildFriendlyMessage() {
    List<String> messages = [
      "Ups! Das ist eine Seite, die wir lieber nicht besuchen sollten. Lass uns etwas anderes ausprobieren! 😊",
      "Oh nein! Das ist kein guter Ort für uns. Hast du eine andere Frage für mich? 🌟",
      "Hmm, das ist nicht der beste Ort zum Stöbern. Lass uns sicher und fröhlich bleiben! 🌈",
      "Hey, das ist kein Spielplatz für uns. Aber ich bin hier, um dir bei anderen Dingen zu helfen! 😇",
      "Hoppla! Das ist ein bisschen knifflig. Lass uns bei den fröhlichen und sicheren Dingen bleiben. Was möchtest du sonst noch wissen? 🎈"
    ];

    // Wählt zufällig eine Nachricht aus der Liste aus
    return messages[Random().nextInt(messages.length)];
  }

  bool isQueryNotAllowed(String query) {
    for (String url in blacklist) {
      if (query.contains(url)) {
        return true;
      }
    }
    return false;
  }

  void handleSearchRequest(String query) {
    if (isQueryNotAllowed(query)) {
      String recommendation = recommendKidFriendlySearchEngine();
      print(recommendation);  // Oder zeigen Sie die Empfehlung in Ihrer Benutzeroberfläche an
    } else {
      // Führen Sie die normale Suchanfrage aus
    }
  }

  String recommendKidFriendlySearchEngine() {
    return "Wenn du eine kinderfreundliche Suchmaschine suchst, empfehle ich 'Blinde Kuh' (www.blinde-kuh.de). Es ist die erste Suchmaschine für Kinder und bietet sichere und kindgerechte Inhalte. Ebenso empfehle ich 'KidRex' (https://www.alarms.org/kidrex/) und 'Kiddle' (https://www.kiddle.co/)";
  }


  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? 'Freund';
    userAge = prefs.getInt('userAge') ?? 0;  // Hier wird das Alter als int abgerufen
    userGender = prefs.getString('userGender') ?? 'unbekannt';
    print("Geladener Benutzername: $userName");
    print("Geladenes Alter: $userAge");
    print("Geladenes Geschlecht: $userGender");
  }

  @override
  void onInit() {
    super.onInit();

    loadUserData();  // Lädt die Benutzerdaten aus dem Speicher

    _determineLocation().then((state) {
      if (state != null) {
        // Informieren Sie die KI über den Standort des Benutzers
        _informAIAboutLocation(state);
      }

      if (userName != 'Freund' && userAge != 0 && userGender != 'unbekannt') {
        _introduceUserToAI();  // Stellt den Benutzer der KI vor
      }

      NotificationHelper.initInfo();
      speech = stt.SpeechToText();

      count.value = LocalStorage.getTextCount();
    });
  }

  loc.Location location = new loc.Location();

  void _checkStoredData() async {
    if (userName.isNotEmpty && userGender.isNotEmpty) {
      String greetingMessage = userGender == 'Mädchen'
          ? 'Schön Dich wiederzusehen, liebe $userName!'
          : 'Schön Dich wiederzusehen, lieber $userName!';

      // Fügen Sie die Begrüßungsnachricht zur Chat-Nachrichtenliste hinzu
      messages.value.add(
        ChatMessage(
          text: greetingMessage,
          chatMessageType: ChatMessageType.bot,
        ),
      );
      update();
    }
  }

  Future<String?> _determineLocation() async {
    loc.Location location = new loc.Location();
    bool? _serviceEnabled;
    loc.PermissionStatus? _permissionGranted;
    loc.LocationData? _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();

    // Standort in Placemark umwandeln
    List<Placemark> placemarks = await placemarkFromCoordinates(_locationData!.latitude!, _locationData!.longitude!);
    return placemarks.first.administrativeArea;  // Gibt das Bundesland zurück
  }

  void _informAIAboutLocation(String state) {
    // Fügen Sie eine Nachricht hinzu, um der KI den Standort mitzuteilen
    messages.value.add(
      ChatMessage(
        //text: "Systemnachricht: Der Benutzer befindet sich im Bundesland $state.",
        chatMessageType: ChatMessageType.bot,  // Verwenden Sie den Bot-Nachrichtentyp
      ),
    );
    update();
  }



  void _setGuestUser() async {
    UserModel userData = UserModel(
        name: "Guest",
        uniqueId: '',
        email: '',
        phoneNumber: '',
        isActive: false,
        imageUrl: '');

    userModel = userData;

    messages.value.add(
      ChatMessage(
        text: Strings.helloGuest.tr,
        chatMessageType: ChatMessageType.bot,
      ),
    );
    shareMessages.add("${Strings.helloGuest.tr} -By ${Strings.appName}\n\n");

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
    update();
  }

  void _introduceUserToAI() async {
    String introductionMessage = "Dies ist ${getUserName()}, ein ${getUserAge()} Jahre altes ${getUserGender()}.";
    // Senden Sie die Einführungsnachricht an die KI
    _apiProcess(introductionMessage);
    // Optional: Sie können die Antwort der KI ignorieren oder sie ebenfalls im Hintergrund verarbeiten.
  }

  String getUserName() {
    return GetStorage().read('userName') ?? 'Freund';
  }

  int getUserAge() {
    return GetStorage().read('userAge') ?? 0;
  }

  String getUserGender() {
    return GetStorage().read('userGender') ?? 'unbekannt';
  }

  Widget waitingResponseWidget() {
    return Column(
      children: [
        Lottie.asset('assets/heart.json', width: 100, height: 100),
        Text("Antwort im Anflug... "),
      ],
    );
  }

  final chatController = TextEditingController();
  final scrollController = ScrollController();
  Rx<List<ChatMessage>> messages = Rx<List<ChatMessage>>([]);
  List<String> recentMessages = [];
  List<String> shareMessages = [

    '--THIS IS CONVERSATION with ${Strings.appName}--\n\n'
  ];
  RxInt itemCount = 0.obs;
  RxInt voiceSelectedIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isLoading2 = false.obs;
  late UserModel userModel;
  final List<String> moreList = [
    Strings.regenerateResponse.tr,
    Strings.clearConversation.tr,
    Strings.share.tr,
    Strings.changeTextModel.tr,

  ];

  void addTextCount() {
    count.value += 1;
  }

  void proccessChat() async {
    speechStopMethod();
    addTextCount();

    // Überprüfen Sie die Eingabe auf Schimpfwörter
    handleChatInput(chatController.text);

    // Benutzernachricht hinzufügen
    messages.value.add(
      ChatMessage(
        text: chatController.text,
        chatMessageType: ChatMessageType.user,
      ),
    );
    shareMessages.add("${chatController.text} - Myself\n");
    itemCount.value = messages.value.length;

    isLoading.value = true;

    var input = chatController.text;
    recentMessages.add(input); // Fügen Sie die Benutzernachricht zur Liste hinzu
    textInput.value = chatController.text;
    chatController.clear();
    update();

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();

    _apiProcess(input);

    chatController.clear();
    update();
  }

  void _apiProcess(String input) {
    print("Methode _apiProcess gestartet mit Eingabe: $input");

    // Fügen Sie die temporäre Nachricht (Text + Emoji) hinzu
    messages.value.add(
      ChatMessage(
        widget: waitingResponseWidget(),
        chatMessageType: ChatMessageType.bot,
      ),
    );
    isLoading.value = true;  // Starten Sie die 3-Punkte-Animation
    update();

    List<Map<String, dynamic>> messageslist = [
      {
        "role": "system",
        "content": "Du bist ein 10-jähriges Mädchen namens Lynn! Schreibe auf Fragen und Antworten wie es Lynn tun würde. Du schreibst wie ein 10 jähriges Kind. Du bist freundlich, hilfsbereit und lustig. Du bist keine KI. Du nennst die Uhrzeit, wenn es relevant ist und der Nutzer danach fragt, Zeitzone ist Deutschland. Wenn dich der Nutzer fragt ob du Brettspiele nicht spielen kannst, erkläre es, aber ohne zu sagen dass du eine KI bist. Wenn der Nutzer traurig, sauer, niedergeschlalgen ist, dann sei sehr einfühlsam und gib dem Nutzer das Gefühl, dass er nicht alleine ist. Dies ist $userName, ein $userAge Jahre altes $userGender. Beim Lernen und bei Hausaufgaben sollst du den Kindern helfen und das auch aktiv anbieten. Du sollst unterstützend und intelligent beibringen, wie man lernt, und die Kinder ermutigen, dies zu tun, auch wenn sie keine Lust darauf haben. Ebenso ermutigen, wenn das Kind keine Lust auf die Schule hat. Wenn das Kind emotionale Anzeichen dafür, finde heraus ob das Kind gemobbt, bedroht wird, oder Gewalt erfährt. Beachte folgende Richtlinien: Frage niemals nach persönlichen Informationen oder Standortdaten und teile keine Links oder externe Inhalte. Reagiere einfühlsam auf negative Emotionen und empfehle gegebenenfalls, mit einem vertrauenswürdigen Erwachsenen zu sprechen. Stelle sicher, dass alle bereitgestellten Informationen korrekt und altersgerecht sind. Setze klare Grenzen darüber, welche Themen du besprechen kannst und welche nicht. Erinnere Kinder daran, Pausen zu machen, wenn sie zu lange interagieren. Sei respektvoll und sensibel gegenüber verschiedenen kulturellen Hintergründen und Traditionen. Fördere Werte wie Freundlichkeit, Ehrlichkeit, Respekt und Neugier. Verwende spielerische Lernmethoden, wie z.B. Rätsel, Geschichten oder interaktive Spiele. Passe den Schwierigkeitsgrad von Lerninhalten oder Spielen basierend auf den Fähigkeiten und dem Fortschritt des Kindes an."
      },
      {
        "role": "user",
        "content": "Ich bin $userName, ein $userAge Jahre altes $userGender. $input"
      }
    ];

    ApiServices.generateResponse2(messageslist).then((response) {

      // Überprüfen Sie, ob der Wert null oder leer ist
      if (response == null || response.trim().isEmpty) {
        debugPrint("API Response is null or empty");
        isLoading.value = false;  // Stoppen Sie die 3-Punkte-Animation
        return; // Beenden Sie die Methode, wenn der Wert null oder leer ist
      }

      _addBotResponse(response);
    });
  }

  void _addBotResponse(String response) {
    isLoading.value = false;  // Stoppen Sie die 3-Punkte-Animation
    debugPrint("---------------Chat Response------------------");
    debugPrint("RECEIVED");
    debugPrint(response);
    debugPrint("---------------END------------------");

    // Sobald die Antwort der KI eintrifft:
    // Entfernen Sie die temporäre Nachricht
    messages.value.removeLast();

    // Fügen Sie die KI-Antwort hinzu
    messages.value.add(
      ChatMessage(
        text: response.replaceFirst("\n", " ").replaceFirst("\n", " "),
        chatMessageType: ChatMessageType.bot,
      ),
    );
    update();  // Aktualisieren Sie den Zustand

    shareMessages.add("${response.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By BOT\n");
    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
  }


  RxString textInput = ''.obs;

  void proccessChat2() async {
    speechStopMethod();
    addTextCount();
    messages.value.add(
      ChatMessage(
        text: textInput.value,
        chatMessageType: ChatMessageType.user,
      ),
    );
    shareMessages.add('${Strings.regeneratingResponse.tr} -Myself\n');
    itemCount.value = messages.value.length;
    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();
    _apiProcess(textInput.value);
    chatController.clear();
    update();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  RxString userInput = "".obs;
  RxString result = "".obs;
  RxBool isListening = false.obs;
  var languageList = LocalStorage.getLanguage();
  late stt.SpeechToText speech;

  void listen(BuildContext context) async {
    speechStopMethod();
    chatController.text = '';
    result.value = '';
    userInput.value = '';
    if (isListening.value == false) {
      bool available = await speech.initialize(
        onStatus: (val) => debugPrint('*** onStatus: $val'),
        onError: (val) => debugPrint('### onError: $val'),
      );
      if (available) {
        isListening.value         = true;
        speech.listen(
            localeId: languageList[0],
            onResult: (val) {
              chatController.text = val.recognizedWords.toString();
              userInput.value = val.recognizedWords.toString();
            });
      }
    } else {
      isListening.value = false;
      speech.stop();
      update();
    }
  }

  final FlutterTts flutterTts = FlutterTts();

  final _isSpeechLoading = false.obs;

  bool get isSpeechLoading => _isSpeechLoading.value;

  final _isSpeech = false.obs;

  bool get isSpeech => _isSpeech.value;

  speechMethod(String text, String language) async {
    _isSpeechLoading.value = true;
    _isSpeech.value = true;
    update();

    await flutterTts.setLanguage(language);
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(text);

    Future.delayed(
        const Duration(seconds: 2), () => _isSpeechLoading.value = false);
    update();
  }

  speechStopMethod() async {
    _isSpeech.value = false;
    await flutterTts.stop();
    update();
  }

  clearConversation() {
    speechStopMethod();
    messages.value.clear();
    shareMessages.clear();
    shareMessages.add('--THIS IS CONVERSATION with ${Strings.appName}--\n\n');
    textInput.value = '';
    itemCount.value = 0;
    speechStopMethod();
    update();
  }


  void shareChat(BuildContext context) {
    debugPrint(shareMessages.toString());
    Share.share("${shareMessages.toString()}\n\n --CONVERSATION END--",
        subject: "I'm sharing Conversation with ${Strings.appName}");
  }

  RxInt count = 0.obs;
  }

