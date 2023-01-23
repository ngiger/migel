{
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02lys9pnb99hsczs551iqzjn008i8k7c728xxba7acfi9rdw9pa6";
      type = "gem";
    };
    version = "7.0.1";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "022r3m9wdxljpbya69y2i3h9g3dhhfaqzidf95m6qjzms792jvgp";
      type = "gem";
    };
    version = "2.8.0";
  };
  akami = {
    dependencies = ["gyoku" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "168y57kd9wshzqqk127w7lknd8lr0b9k50wazw4c92zshq3sw2jd";
      type = "gem";
    };
    version = "1.3.1";
  };
  builder = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  chrono_logger = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1p412f9cv5cmkbvifw762rdzg4aprxdn8mdgyddqh3zlq2z992ik";
      type = "gem";
    };
    version = "1.1.2";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nwad3211p7yv9sda31jmbyw6sdafzmdi2i2niaz6f0wk5nq9h0f";
      type = "gem";
    };
    version = "1.1.9";
  };
  connection_pool = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ffdxhgirgc86qb42yvmfj6v1v0x4lvi0pxn9zhghkff44wzra0k";
      type = "gem";
    };
    version = "2.2.5";
  };
  crack = {
    dependencies = ["rexml"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cr1kfpw3vkhysvkk3wg7c54m75kd68mbm9rs5azdjdq57xid13r";
      type = "gem";
    };
    version = "0.4.5";
  };
  deprecated = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1777y6wmwx1w78bjm61kn0l683wc68pzdwh9rihvcq2pl7vyjj2n";
      type = "gem";
    };
    version = "2.0.1";
  };
  diff-lcs = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rwvjahnp7cpmracd8x732rjgnilqv2sx7d1gfrysslc3h039fa9";
      type = "gem";
    };
    version = "1.5.0";
  };
  digest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00vwzvxgby22h7jhwadqqf9ssbkp3ag2pl4g7q3zf1y8mlk7rk39";
      type = "gem";
    };
    version = "3.1.0";
  };
  docile = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lxqxgq71rqwj1lpl9q1mbhhhhhhdkkj7my341f2889pwayk85sz";
      type = "gem";
    };
    version = "1.4.0";
  };
  domain_name = {
    dependencies = ["unf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lcqjsmixjp52bnlgzh4lg9ppsk52x9hpwdjd53k8jnbah2602h0";
      type = "gem";
    };
    version = "0.5.20190701";
  };
  flexmock = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17azyd02q246f9cacsjklvh1nj4nn257niw5gm22afml07fwg70x";
      type = "gem";
    };
    version = "1.3.3";
  };
  gyoku = {
    dependencies = ["builder"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wn0sl14396g5lyvp8sjmcb1hw9rbyi89gxng91r7w4df4jwiidh";
      type = "gem";
    };
    version = "1.3.1";
  };
  hashdiff = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nynpl0xbj0nphqx1qlmyggq58ms1phf5i03hk64wcc0a17x1m1c";
      type = "gem";
    };
    version = "1.0.1";
  };
  hpricot = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jn8x9ch79gqmnzgyz78kppavjh5lqx0y0r6frykga2b86rz9s6z";
      type = "gem";
    };
    version = "0.8.6";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13rilvlv8kwbzqfb644qp6hrbsj82cbqmnzcvqip1p6vqx36sxbk";
      type = "gem";
    };
    version = "1.0.5";
  };
  httpi = {
    dependencies = ["rack" "socksify"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v8ah9indflp0w6jdzkzgs72xiwbam5v1c58migj0dkavkrai45h";
      type = "gem";
    };
    version = "2.5.0";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vdd1kii40qhbr9n8qx71k2gskq6rkl8ygy8hw5hfj8bb5a364xf";
      type = "gem";
    };
    version = "1.8.11";
  };
  io-wait = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10jj6xz15qaw8gkck5wv3a3xg1zdfsarrandkglfbf75x4xmkrfz";
      type = "gem";
    };
    version = "0.2.1";
  };
  json = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z9grvjyfz16ag55hg522d3q4dh07hf391sf9s96npc0vfi85xkz";
      type = "gem";
    };
    version = "2.6.1";
  };
  mail = {
    dependencies = ["mini_mime"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
    };
    version = "2.7.1";
  };
  mechanize = {
    dependencies = ["addressable" "domain_name" "http-cookie" "mime-types" "net-http-digest_auth" "net-http-persistent" "nokogiri" "rubyntlm" "webrick" "webrobots"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1adjnzvq3rxqz7xf3qr7c0p85ccfwmn0l3fcmch6cjwz0i9vc5ah";
      type = "gem";
    };
    version = "2.8.5";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ipw892jbksbxxcrlx9g5ljq60qx47pm24ywgfbyjskbcl78pkvb";
      type = "gem";
    };
    version = "3.4.1";
  };
  mime-types-data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "003gd7mcay800k2q4pb2zn8lwwgci4bhi42v2jvlidm8ksx03i6q";
      type = "gem";
    };
    version = "3.2022.0105";
  };
  mimemagic = {
    dependencies = ["nokogiri" "rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17ycgsmz2229jh224ws77yg974cz326flgc401xrdkfpw90jvb08";
      type = "gem";
    };
    version = "0.4.3";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lbim375gw2dk6383qirz13hgdmxlan0vc5da2l072j3qw6fqjm5";
      type = "gem";
    };
    version = "1.1.2";
  };
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rapl1sfmfi3bfr68da4ca16yhc0pp93vjwkj7y3rdqrzy3b41hy";
      type = "gem";
    };
    version = "2.8.0";
  };
  minitest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06xf558gid4w8lwx13jwfdafsch9maz8m0g85wnfymqj63x5nbbd";
      type = "gem";
    };
    version = "5.15.0";
  };
  net-http-digest_auth = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nq859b0gh2vjhvl1qh1zrk09pc7p54r9i6nnn6sb06iv07db2jb";
      type = "gem";
    };
    version = "1.4.1";
  };
  net-http-persistent = {
    dependencies = ["connection_pool"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yfypmfg1maf20yfd22zzng8k955iylz7iip0mgc9lazw36g8li7";
      type = "gem";
    };
    version = "4.0.1";
  };
  net-imap = {
    dependencies = ["digest" "net-protocol" "strscan"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rl79ykmxa2k4dlk6ykrb9l0a4h101q1gd8c4qv3cl0p9h68zmbn";
      type = "gem";
    };
    version = "0.2.3";
  };
  net-pop = {
    dependencies = ["digest" "net-protocol" "timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1slsl3xlbf0cqzmf2q1rfqbm61xvxzmr0h9zprwlbm1xn1cvn9xb";
      type = "gem";
    };
    version = "0.1.1";
  };
  net-protocol = {
    dependencies = ["io-wait" "timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rrzdar609d8c96ikpw2yif44pp5k3n3cpjld31ia0rgmz9z59gv";
      type = "gem";
    };
    version = "0.1.2";
  };
  net-smtp = {
    dependencies = ["digest" "net-protocol" "timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s358kfv9mnfxcjbpr1d5a2gs1q7wkw7ffpn86mf1b3s9p31bw9s";
      type = "gem";
    };
    version = "0.3.1";
  };
  nokogiri = {
    dependencies = ["mini_portile2" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n79k78c5vdcyl0m3y3l5x9kxl6xf5lgriwi2vd665qmdkr01vnk";
      type = "gem";
    };
    version = "1.13.10";
  };
  nori = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "066wc774a2zp4vrq3k7k8p0fhv30ymqmxma1jj7yg5735zls8agn";
      type = "gem";
    };
    version = "2.6.0";
  };
  odba = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xzw0r1q5mn0hxgx6ph6iqyg64lm918i3w8vxdjdn43aj202z0b2";
      type = "gem";
    };
    version = "1.1.8";
  };
  pg = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13mfrysrdrh8cka1d96zm0lnfs59i5x2g6ps49r2kz5p3q81xrzj";
      type = "gem";
    };
    version = "1.2.3";
  };
  psych = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10iawnkpa44hcfrapy7yw6zmjn4g1g0y09lw244qiv424f7jasn5";
      type = "gem";
    };
    version = "3.3.2";
  };
  public_suffix = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f3knlwfwm05sfbaihrxm4g772b79032q14c16q4b38z8bi63qcb";
      type = "gem";
    };
    version = "4.0.7";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p685i23lr8pl7l09g9l2mcj615fr7g33w3mkcr472lcg34nq8n8";
      type = "gem";
    };
    version = "1.6.1";
  };
  rack = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b1qsg0yfargdhmpapp2d3mlxj82wyygs9nj74w0r03diyi8swlc";
      type = "gem";
    };
    version = "2.2.3.1";
  };
  rake = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15whn7p9nrkxangbs9hh75q585yfn66lv0v2mhj6q6dl6x8bzr2w";
      type = "gem";
    };
    version = "13.0.6";
  };
  rclconf = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r58zdn7lfgpja8hxs730qjqhycwhnhm989x9b7raa561zq0bdy1";
      type = "gem";
    };
    version = "1.0.0";
  };
  rexml = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dwai7jnwmdmd7ajbi2q0k0lx1dh88knv5wl7c34wjmf94yv8w5q";
      type = "gem";
    };
    version = "3.10.0";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wwnfhxxvrlxlk1a3yxlb82k2f9lm0yn0598x7lk8fksaz4vv6mc";
      type = "gem";
    };
    version = "3.10.1";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qrj2j9jcd3m4aksk4kbv439882yl3z1harv2jrybrgjgdzdz7zs";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d13g6kipqqc9lmwz5b244pdwc97z15vcbnbq6n9rlf32bipdz4k";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec-support = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pjckrh8q6sqxy38xw7f4ziylq1983k84xh927s6352pps68zj35";
      type = "gem";
    };
    version = "3.10.3";
  };
  ruby-ole = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zhaq66csdingjw34acnq3j56s0s1vhxvb1cnglw9vca958g0rvx";
      type = "gem";
    };
    version = "1.2.12.2";
  };
  rubyntlm = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b8hczk8hysv53ncsqzx4q6kma5gy5lqc7s5yx8h64x3vdb18cjv";
      type = "gem";
    };
    version = "0.6.3";
  };
  savon = {
    dependencies = ["akami" "builder" "gyoku" "httpi" "nokogiri" "nori" "wasabi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19ry5ww84bv31k5617p5k7qpdyar4fqjxhvk54vfgcwkg7nlan2h";
      type = "gem";
    };
    version = "2.12.1";
  };
  sbsm = {
    dependencies = ["chrono_logger" "hpricot" "mail" "mimemagic" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12l8ngw32v9a8wqxz8rwhsl09xq6lgrqx7yby42z2b9axn0fq93r";
      type = "gem";
    };
    version = "1.6.0";
  };
  simplecov = {
    dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hrv046jll6ad1s964gsmcq4hvkr3zzr6jc7z1mns22mvfpbc3cr";
      type = "gem";
    };
    version = "0.21.2";
  };
  simplecov-html = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yx01bxa8pbf9ip4hagqkp5m0mqfnwnw2xk8kjraiywz4lrss6jb";
      type = "gem";
    };
    version = "0.12.3";
  };
  simplecov_json_formatter = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19r15hyvh52jx7fmsrcflb58xh8l7l0zx4sxkh3hqzhq68y81pjl";
      type = "gem";
    };
    version = "0.1.3";
  };
  socksify = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fp4p8p4y713lh00rd31xymxnzkbhmg0d12ixbqs7lcaj2pcgcni";
      type = "gem";
    };
    version = "1.7.1";
  };
  spreadsheet = {
    dependencies = ["ruby-ole"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dlhfp69wk0ryffia8cw9ygzq73m7b21g046cma208k422bxfg79";
      type = "gem";
    };
    version = "1.3.0";
  };
  strscan = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05bzfzfwvs5ngl14yf303nvrg5wjx3srgbjqkki7x65cm66w948p";
      type = "gem";
    };
    version = "3.0.1";
  };
  timeout = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10bx1hcyrjqgq6a848fc1i0cgrvx42gcy8hk4vp90y6zc7k8xzbk";
      type = "gem";
    };
    version = "0.2.0";
  };
  travis-lint = {
    dependencies = ["json"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1spaq9a6d1mxcb5jzmlyg6phhd518cfwwfmbf71xcy6j6892c60r";
      type = "gem";
    };
    version = "2.0.0";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10qp5x7f9hvlc0psv9gsfbxg4a7s0485wsbq1kljkxq94in91l4z";
      type = "gem";
    };
    version = "2.0.4";
  };
  unf = {
    dependencies = ["unf_ext"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yj2nz2l101vr1x9w2k83a0fag1xgnmjwp8w8rw4ik2rwcz65fch";
      type = "gem";
    };
    version = "0.0.8.2";
  };
  wasabi = {
    dependencies = ["addressable" "httpi" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rzmh6knnj8pmw6slc6393dxpb6k47lcac3889i7g5nyhfcn9xbp";
      type = "gem";
    };
    version = "3.6.1";
  };
  webmock = {
    dependencies = ["addressable" "crack" "hashdiff"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1l8vh8p0g92cqcvv0ra3mblsa4nczh0rz8nbwbkc3g3yzbva85xk";
      type = "gem";
    };
    version = "3.14.0";
  };
  webrick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d4cvgmxhfczxiq5fr534lmizkhigd15bsx5719r5ds7k7ivisc7";
      type = "gem";
    };
    version = "1.7.0";
  };
  webrobots = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19ndcbba8s8m62hhxxfwn83nax34rg2k5x066awa23wknhnamg7b";
      type = "gem";
    };
    version = "0.1.2";
  };
  ydbd-pg = {
    dependencies = ["pg" "ydbi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "069bn2fnnj771x17pdxnl1lir8r27j0xnfjjvghb3y2r3nhdnx6x";
      type = "gem";
    };
    version = "0.5.9";
  };
  ydbi = {
    dependencies = ["deprecated"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0w14lr243zb7bqkz5nz6rvnmhqjdwhd2n9qqq728v61xcgmrp6l7";
      type = "gem";
    };
    version = "0.5.9";
  };
}
