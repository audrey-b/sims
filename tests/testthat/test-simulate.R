context("sims-simulate")

test_that("test inputs", {
  expect_error(sims_simulate(1),
    "`code` must be a string [(]non-missing character scalar[)].",
    class = "chk_error"
  )

  expect_error(sims_simulate("x <- y", 1),
    "^`constants` must inherit from S3 class 'nlist'[.]$",
    class = "chk_error"
  )
  expect_error(sims_simulate("x <- y", nlist(x = NA_real_)),
    "^`constants` must not have any missing values[.]$",
    class = "chk_error"
  )
  expect_error(sims_simulate("x <- y", parameters = list(x = TRUE)),
    "^All elements of `parameters` must be numeric[.]$",
    class = "chk_error"
  )
  expect_error(sims_simulate("x <- y", parameters = list(x = NA_real_)),
    "^`parameters` must not have any missing values[.]$",
    class = "chk_error"
  )
  expect_error(sims_simulate("x <- y", list(x = 1), monitor = 1),
    "`monitor` must inherit from S3 class 'character'",
    class = "chk_error"
  )
})

test_that("test nodes not already defined", {
  expect_error(
    sims_simulate("a ~ dunif(1)", nlist(a = 1)),
    "^The following variable nodes are defined in constants: 'a'[.]$"
  )
})

test_that("test match at least one node", {
  expect_error(
    sims_simulate("a ~ dunif(1)", list(x = 1),
      monitor = "b",
      stochastic = TRUE, latent = FALSE
    ),
    paste0("^`monitor` must match at least one of the following",
    " observed stochastic variable nodes: 'a'[.]$")
  )
  expect_error(
    sims_simulate("a ~ dunif(1)", list(x = 1), monitor = "b"),
    paste0("^`monitor` must match at least one of the following variable",
    " nodes: 'a'[.]$")
  )
  expect_error(
    sims_simulate("a ~ dunif(1)", list(x = 1),
      monitor = "b",
      stochastic = FALSE, latent = FALSE
    ),
    paste0("^JAGS code must include at least one observed",
    " deterministic variable node[.]$")
  )
  expect_error(
    sims_simulate("a ~ dunif(1)", list(x = 1),
      monitor = "b",
      stochastic = FALSE
    ),
    "^JAGS code must include at least one deterministic variable node[.]$"
  )
  expect_error(
    sims_simulate("a ~ dunif(1)
                             a2 <- a", list(x = 1),
      monitor = "b",
      stochastic = FALSE, latent = FALSE
    ),
    paste0("^`monitor` must match at least one of the following",
    " observed deterministic variable nodes: 'a2'[.]$")
  )
  expect_error(
    sims_simulate("a ~ dunif(1)
                             a2 <- a", list(x = 1),
      monitor = "b",
      stochastic = FALSE
    ),
    paste0("^`monitor` must match at least one of the following",
    " deterministic variable nodes: 'a2'[.]$")
  )
  expect_error(
    sims_simulate("a ~ dunif(1)
                             a2 <- a", list(x = 1),
      monitor = "b",
      stochastic = NA, latent = NA
    ),
    paste0("^`monitor` must match at least one of the following",
    " variable nodes: 'a' or 'a2'[.]$")
  )
})

test_that("not in model or data block", {
  expect_error(
    sims_simulate("model {a ~ dunif(1)}", nlist(x = 1), monitor = "a"),
    "^JAGS code must not be in a data or model block."
  )
  expect_error(
    sims_simulate("\n data\n{a ~ dunif(1)}", nlist(x = 1), monitor = "a"),
    "^JAGS code must not be in a data or model block."
  )
})

test_that("generates data with replicability", {
  set.seed(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.749735354622374))
  )
  set.seed(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.749735354622374))
  )
  set.seed(-1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.315564033523335))
  )
  set.seed(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.749735354622374))
  )
})

test_that("generates data with replicability if repeated calls", {
  set.seed(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.749735354622374))
  )
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.229132551657083))
  )
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.534957256848294))
  )
  set.seed(1)
  runif(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.229132551657083))
  )
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.534957256848294))
  )
  set.seed(1)
  runif(2)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.534957256848294))
  )
})

test_that("save", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)

  set.seed(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.749735354622374))
  )
  set.seed(1)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)", save = NA, path = tempdir),
    nlist::nlists(nlist(a = 0.749735354622374))
  )
  expect_identical(
    sims_data_files(tempdir),
    "data0000001.rds"
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.749735354622374)
  )
  set.seed(1)
  unlink(tempdir, recursive = TRUE)
  expect_true(sims_simulate("a ~ dunif(0,1)", save = TRUE, path = tempdir))
  expect_identical(
    sims_data_files(tempdir),
    "data0000001.rds"
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.749735354622374)
  )
})

test_that("gets deterministic nodes", {
  generative_model <- "
for (i in 1:length(year)) {
  cc[i] ~ dpois(lambda[i])
  log(lambda[i]) <- alpha + beta1 * year[i]
}
rand ~ dnorm(0,1)
"
  monitor <- c("cc", "rand", "lambda")

  parameters <- nlist(alpha = 3.5576, beta1 = -0.0912)

  constants <- nlist(year = 1:5)

  set.seed(2)
  expect_equal(
    sims_simulate(generative_model,
      constants = constants,
      parameters = parameters,
      monitor = monitor, stochastic = NA, latent = NA
    ),
    nlist::nlists(nlist(cc = c(27, 38, 36, 21, 13), lambda = c(
      32.0212581683725,
      29.2301292225158, 26.6822886806137, 24.3565303394963, 22.2334964320294
    ), rand = 0.323078183488302, year = 1:5))
  )
})

test_that("gets deterministic nodes with R code", {
  generative_model <- "
  lambda <- exp(alpha + beta1 * year)
  cc <- rpois(year, lambda)
  rand <- rnorm(1, 0, 1)
"
  monitor <- c("cc", "rand", "lambda")

  parameters <- nlist(alpha = 3.5576, beta1 = -0.0912)

  constants <- nlist(year = 1:5)

  set.seed(2)
  expect_equal(
    sims_simulate(generative_model,
      constants = constants,
      parameters = parameters,
      monitor = monitor, stochastic = NA, latent = NA
    ),
    nlist::nlists(nlist(
      cc = c(27L, 36L, 27L, 26L, 19L),
      rand = -0.50015572039553, lambda = c(
        32.0212581683725, 29.2301292225158,
        26.6822886806137, 24.3565303394963, 22.2334964320294
      ), year = 1:5
    ))
  )
})

test_that("nsims can take numeric", {
  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.342673102637473))
  )
})

test_that("nsims > 1", {
  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)", nsims = 2L),
    nlist::nlists(
      nlist(a = 0.342673102637473),
      nlist(a = 0.0584777028255878)
    )
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)", nsims = 2L),
    nlist::nlists(
      nlist(a = 0.342673102637473),
      nlist(a = 0.0584777028255878)
    )
  )
})

test_that("write replicable", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)

  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)", path = tempdir, save = TRUE))
  expect_error(
    sims_simulate("a ~ dunif(0,1)", path = tempdir, save = TRUE),
    "must not already exist"
  )
  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))

  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_identical(
    sims_data_files(tempdir),
    "data0000001.rds"
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.342673102637473)
  )

  expect_identical(
    sims_info(tempdir),
    list(
      code = "model{a ~ dunif(0,1)}\n", constants = nlist(),
      parameters = nlist(),
      monitor = "a", nsims = 1L, seed = c(
        10403L, 624L, 853008081L,
        -1946219938L, 421532487L, -755954980L, 862903853L, -1354943734L,
        -1566351101L, -372976024L, 132839753L, 1058755702L, 1084399743L,
        -1528825676L, 1605323813L, -765273438L, 1491422651L, 575454656L,
        450278081L, 398586254L, -786389833L, -1002950260L, 756009245L,
        -1409841862L, -869031565L, -973201384L, -1808209095L, -2134949466L,
        287506415L, 2146768228L, -21220075L, -1065512238L, 399850539L,
        637164912L, 2108392113L, -626285378L, 2005832231L, -1933704132L,
        1587310605L, 620979050L, 858586595L, 1104074184L, 155474217L,
        1030453974L, 522468191L, 40263188L, 2094291461L, 413357826L,
        1564067483L, 1559554336L, -921350495L, 1773085678L, -1442784361L,
        158171884L, -1622945027L, -838611558L, -132745645L, 1146222456L,
        -693353703L, -361562106L, -1793240369L, 947835588L, -2130265355L,
        1691821874L, -730206965L, 1136091344L, -359459183L, 1719627550L,
        -70352633L, -1577996900L, -1577782803L, 324781002L, -315159869L,
        -882735832L, 1674553609L, 568906038L, -884652481L, -1857457292L,
        -2044569627L, 2145125218L, -1833128069L, -981678976L, 1063508609L,
        -1349548466L, 1712226935L, -122321844L, -446772003L, 1244546554L,
        110476083L, -1684308264L, -3306759L, -761270682L, -1215097425L,
        -1903083484L, -894029611L, -986387566L, -2031546901L, -331344848L,
        -2071553423L, -1877841538L, -1214783513L, -1696332036L, -1544526899L,
        -530688982L, -906393693L, -262675320L, -779818775L, 1881888662L,
        1572716831L, 1960917204L, 1091651013L, 1092935618L, -374994853L,
        -1866706976L, -960866719L, -268756818L, 83990871L, -1335347796L,
        -1009207619L, -1936789926L, -1091997677L, 733132344L, -946552103L,
        584977606L, 1060915343L, -75211388L, 2135070389L, -525410318L,
        -1386570037L, 174880656L, 1383992913L, -2080599074L, 413314759L,
        -1410527140L, -955857491L, 2116228234L, -559123325L, -2037976088L,
        -2007230263L, -137687562L, -884626433L, -58347980L, -1357306971L,
        -1584010206L, -298987205L, -544502976L, -1542405567L, -41297138L,
        -493739977L, -86141172L, -1154903907L, -1925331270L, 71931123L,
        -1066426984L, 1643768505L, 281369382L, -825169041L, 615525092L,
        2116283541L, -1034091438L, 1644601259L, 1964280560L, 1467052593L,
        987098686L, -391713369L, -1251685956L, 699406221L, 1791100138L,
        1552404835L, -808996024L, 978139305L, -731909034L, -459995425L,
        -1550920812L, 229765509L, -230217598L, -930346469L, -1094551904L,
        408886817L, 1993592174L, -1233643753L, 1315809388L, 130636413L,
        -799879398L, -705812013L, -1851116296L, 2129986201L, 502126982L,
        -452395441L, -613636028L, -489541003L, -2124982094L, 1529155723L,
        -284144048L, -1839675887L, 2033612958L, 1297915015L, 1134768924L,
        -1503372947L, -1336728246L, -1866228157L, 2045911720L, 357582985L,
        1837238966L, 1449382335L, 290760948L, -699158683L, -1873767198L,
        1022931707L, 658051584L, 1620929025L, -965677106L, -1804894729L,
        -848270900L, -1573907363L, 1709574010L, 1326395059L, 1127906392L,
        1249774201L, 401573862L, -593723089L, 487708068L, 80046165L,
        1085660434L, -353504917L, 657965488L, -30668303L, -810142978L,
        -931415193L, -1895805828L, -744780979L, -454134358L, -459810013L,
        -1629601272L, -1017296791L, 1992904982L, -1452667745L, 422522452L,
        -1099539131L, -456511166L, -1414804517L, -37266080L, -1245469215L,
        586760750L, -333163305L, 1178458924L, 1054195261L, -368087078L,
        -1494965357L, -453479496L, 1821180505L, 409101894L, -331123697L,
        318223108L, 2004192821L, 798003570L, -6733237L, -1201478384L,
        -1847378479L, -1695736482L, 935086663L, 2077496796L, 63810861L,
        715912714L, -583235581L, -1000074904L, 1785477193L, -271726730L,
        1113569151L, -1166646348L, -1215169755L, 1691090338L, 282940603L,
        323311808L, 1288294849L, -1895512946L, -1990550601L, 858651788L,
        1311922205L, -2065233862L, 816220275L, -222553320L, 152693305L,
        -2065795930L, 649451247L, 309739620L, 173712405L, -1996524078L,
        593429291L, 694794352L, 1081500081L, 57882558L, -724154073L,
        -1703506116L, 1165147917L, 799254122L, 468296931L, -597978936L,
        -1401612247L, 606563798L, 1643958879L, 545409300L, -283211515L,
        -1855063550L, 80039323L, 613090336L, 1453845921L, -651462930L,
        -1815719273L, -1164390932L, -54664707L, -360394598L, 1535958355L,
        1415410296L, -1071857127L, 251376390L, 2058070479L, -1662681660L,
        -924014091L, -1810200014L, 2088186891L, -316392496L, -119704175L,
        -35618274L, 897693703L, 658487452L, 1661124845L, 770541258L,
        1574384067L, 1151123496L, -1485838327L, -1418836938L, 620322111L,
        -1565860236L, -829159707L, -137877918L, -1147423109L, -630169728L,
        5634433L, -1677371058L, -1893762697L, -1361686708L, 854612957L,
        1526778106L, -1295015373L, 1572108760L, -1383233031L, -1269685914L,
        -1294144337L, 1604152100L, -89940011L, -1543909742L, -853945109L,
        1651142448L, -1508869775L, 1254947966L, 1266063079L, 176656892L,
        -487214387L, -341731542L, 2084384419L, -956326008L, -179001367L,
        1765427862L, -2079500257L, -1001905196L, -76909371L, 821199554L,
        93884251L, -909284640L, 1925969249L, 1042967470L, 1528696919L,
        -1908506452L, -1790851651L, -1569525414L, -576268525L, -828821192L,
        1768178137L, -1099317306L, 1979817871L, 871762052L, 586646965L,
        397755122L, 1937696203L, -736865648L, 789015889L, 1993385694L,
        1684858311L, -660202660L, 130258093L, -1160259702L, 1817418627L,
        -1722011928L, -1407494199L, -1927053066L, 1408287487L, 884087092L,
        1461310117L, -502984926L, 1324603451L, 1937385024L, -754851519L,
        -231559666L, 863639351L, -2094439924L, -2077614179L, 418597306L,
        -1622508557L, -756836200L, 127461817L, -1022718426L, 1188151919L,
        524768740L, 23092117L, 1516562258L, 1776182955L, 2029643248L,
        1991921969L, -628915906L, 706520231L, -772582212L, -807115123L,
        2041071594L, 1062369379L, 1569353288L, 1572599721L, -1832786090L,
        1163632095L, -817840492L, -15064955L, -1139291262L, -1612345061L,
        1145999776L, 1106230561L, -1229578130L, -1343517161L, 1676604268L,
        471951741L, -1566977510L, -688746285L, 40611832L, 404980121L,
        -1550021498L, -2080025265L, 1391022916L, -1856626315L, -484394062L,
        1181767563L, 1945315664L, 1545676049L, -1703048290L, -1573006457L,
        -490258916L, -170907539L, -1842681782L, 577881411L, 560094632L,
        405702537L, 1101888950L, -452597569L, -1689512972L, 1289969253L,
        2084747234L, -1666860549L, -1792889600L, -594704127L, 1447871182L,
        -1003850505L, -1293470516L, 899654493L, -1350661510L, 2144802227L,
        1628010328L, -1493431943L, -1916290330L, 1750358063L, 741605540L,
        173070165L, 889241618L, 996980843L, -740811600L, -1171003151L,
        -1487485442L, 780694119L, -1552296068L, -268510643L, -92817238L,
        1592361507L, 1589378312L, 1701513065L, -1384233962L, -1683512417L,
        -869525164L, -705852347L, -341978046L, -2056498469L, -1429309344L,
        -1143782175L, 1737397550L, -1074869289L, -1637210580L, 1696386365L,
        1002009306L, -1322251629L, 1586818744L, 1008370009L, -81520314L,
        175557391L, 880762372L, -540508875L, -551750542L, 386632011L,
        -1820278768L, 1743428817L, -1113116578L, -1934327481L, 1482891484L,
        -253199315L, 883341578L, 1509011203L, -76592024L, 1265203017L,
        902576758L, -1376203137L, -1053241676L, 1806740005L, -549379934L,
        913398715L, -1238764608L, -189206335L, 1293129614L, 1324389047L,
        13617036L, -82778339L, -815625414L, -1640665229L, -689564136L,
        -612964039L, -1320573018L, 1562684911L, 555969380L, -1053486315L,
        2089638098L, 1132775979L, -1715137680L, 943538353L, 1711721150L,
        -696647641L, -237299140L, -419099123L, 1322248554L, -1799205917L,
        1230261192L, 1277286185L, -2043715370L, 1018259807L, 97137684L,
        463779845L, 944020738L, 669832347L, -737337568L, -1741255519L,
        896780782L, 2028456343L, 1617959148L, 66318589L, 2123486106L,
        -1776335789L, 299167096L, 84492569L, -1043307002L, 789971151L,
        -747099964L, -1710319371L, -1268126414L, -955221237L, -1182984496L,
        -98315119L, -183659234L, -2121208057L, 205112220L, 2093780973L,
        -485799478L, -1399629629L, 105052968L, 1703683849L, -1774209226L,
        1149858879L, 1362643316L, 792835557L, -473937566L, 1846984059L,
        223345280L, -1287382911L, 457649230L, -1584631689L, -274523572L,
        1212017373L, -379630598L, 69568819L, -1019644712L, -1261860615L,
        -1974447002L, 721601455L, 1490392612L, -1848832299L, 969585042L,
        1139186667L, -1316959696L, 2023118961L, -1957458050L, 1605455335L,
        -271115012L, 414646733L, 393271850L, 1520227747L, 1544772232L,
        295724777L, -1449837162L, -1640435937L, -2032464172L, 738173893L,
        -624155198L, -1188620709L, 1456113120L
      )
    )
  )
})

test_that("write replicable > 1", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)

  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 2L,
    path = tempdir, save = TRUE
  ))
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.342673102637473)
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000002.rds")),
    nlist(a = 0.0584777028255878)
  )
  set.seed(101)
  expect_error(
    sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, save = TRUE),
    "must not already exist"
  )
  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 2L, path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.342673102637473)
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000002.rds")),
    nlist(a = 0.0584777028255878)
  )
  set.seed(100)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.771283060089858)
  )
  expect_identical(list.files(tempdir), "data0000001.rds")
  set.seed(100)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 2L, path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.771283060089858)
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000002.rds")),
    nlist(a = 0.558316438218761)
  )
  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.342673102637473)
  )
})

test_that("monitor", {
  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.342673102637473))
  )

  expect_error(
    sims_simulate("ab ~ dunif(0,1)",
      monitor = c("a", "a"),
      stochastic = TRUE, latent = FALSE
    ),
    paste0("^`monitor` must include at least one of the following",
    " observed stochastic variable nodes: 'ab'[.]$")
  )

  expect_error(
    sims_simulate("ab ~ dunif(0,1)",
      monitor = c("a", "a"),
      stochastic = FALSE, latent = FALSE
    ),
    paste0("^JAGS code must include at least one observed deterministic",
    " variable node[.]$")
  )

  expect_error(
    sims_simulate("ab ~ dunif(0,1)",
      monitor = c("a", "a"),
      stochastic = FALSE, latent = NA
    ),
    "^JAGS code must include at least one deterministic variable node[.]$"
  )

  expect_warning(
    sims_simulate("ab ~ dunif(0,1)",
      monitor = c("ab", "a"),
      stochastic = TRUE, latent = FALSE
    ),
    paste0("^The following in `monitor` are not observed",
    " stochastic variable nodes: 'a'[.]$")
  )
})

test_that("append constants", {
  expect_error(
    sims_simulate("ab ~ dunif(0,1)",
      monitor = c("a", "a"),
      stochastic = TRUE, latent = FALSE
    ),
    paste0("^`monitor` must include at least one of the following",
    " observed stochastic variable nodes: 'ab'[.]")
  )

  expect_warning(
    sims_simulate("ab ~ dunif(0,1)",
      monitor = c("ab", "a"),
      stochastic = TRUE, latent = FALSE
    ),
    paste0("^The following in `monitor` are not observed",
    " stochastic variable nodes: 'a'[.]$")
  )
})

test_that("parallel with registered", {
  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.342673102637473))
  )

  options(mc.cores = 2)
  future::plan(future::multisession)
  teardown(future::plan(future::sequential))

  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)"),
    nlist::nlists(nlist(a = 0.342673102637473))
  )

  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)", nsims = 2),
    nlist::nlists(
      nlist(a = 0.342673102637473),
      nlist(a = 0.0584777028255878)
    )
  )
})

test_that("parallel with registered files", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)

  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 2L,
    path = tempdir, save = TRUE
  ))
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.342673102637473)
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000002.rds")),
    nlist(a = 0.0584777028255878)
  )

  expect_identical(list.files(tempdir), c("data0000001.rds", "data0000002.rds"))
  set.seed(100)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_identical(list.files(tempdir), "data0000001.rds")
  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.771283060089858)
  )

  options(mc.cores = 2)
  future::plan(future::multisession)
  teardown(future::plan(future::sequential))

  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 2L, path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_identical(list.files(tempdir), c("data0000001.rds", "data0000002.rds"))

  expect_equal(
    readRDS(file.path(tempdir, "data0000001.rds")),
    nlist(a = 0.342673102637473)
  )
  expect_equal(
    readRDS(file.path(tempdir, "data0000002.rds")),
    nlist(a = 0.0584777028255878)
  )
})

test_that("write existing with random file not touched", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)

  set.seed(101)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 2L,
    path = tempdir, save = TRUE
  ))
  expect_identical(list.files(tempdir), c("data0000001.rds", "data0000002.rds"))
  expect_error(
    sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, save = TRUE),
    "^Directory '.*sims' must not already exist[.]$"
  )

  expect_warning(
    sims_simulate("a ~ dunif(0,1)",
      path = tempdir, save = TRUE,
      exists = TRUE, ask = FALSE
    ),
    "^Deleted 2 sims data files in '.*sims'[.]$"
  )
  expect_identical(list.files(tempdir), c("data0000001.rds"))

  expect_warning(
    sims_simulate("a ~ dunif(0,1)",
      nsims = 3L, path = tempdir, save = TRUE,
      exists = TRUE, ask = FALSE
    ),
    "^Deleted 1 sims data files in '.*sims'[.]$"
  )
  expect_identical(
    list.files(tempdir),
    c("data0000001.rds", "data0000002.rds", "data0000003.rds")
  )

  x <- 1
  saveRDS(x, file.path(tempdir, "data000003.rds"))

  expect_true(sims_simulate("a ~ dunif(0,1)",
    path = tempdir, save = TRUE,
    exists = TRUE, ask = FALSE, silent = TRUE
  ))
  expect_identical(list.files(tempdir), c("data0000001.rds", "data000003.rds"))
})

test_that("names with dots and underscores", {
  set.seed(101)
  expect_equal(
    sims_simulate("x.y ~ dunif(0,1)", nsims = 2L),
    nlist::nlists(
      nlist(x.y = 0.342673102637473),
      nlist(x.y = 0.0584777028255878)
    )
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x_y ~ dunif(0,1)", nsims = 2L),
    nlist::nlists(
      nlist(x_y = 0.342673102637473),
      nlist(x_y = 0.0584777028255878)
    )
  )
})

test_that("stochastic nodes", {
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                             y <- x", stochastic = NA, latent = NA),
    nlist::nlists(nlist(x = 0.342673102637473, y = 0.342673102637473))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                             y <- x", stochastic = TRUE, latent = NA),
    nlist::nlists(nlist(x = 0.342673102637473))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                             y <- x", stochastic = FALSE, latent = NA),
    nlist::nlists(nlist(y = 0.342673102637473))
  )
})

test_that("latent nodes", {
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                             y <- x", stochastic = NA, latent = NA),
    nlist::nlists(nlist(x = 0.342673102637473, y = 0.342673102637473))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                             y <- x", stochastic = NA, latent = FALSE),
    nlist::nlists(nlist(y = 0.342673102637473))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                             y <- x", stochastic = NA, latent = TRUE),
    nlist::nlists(nlist(x = 0.342673102637473))
  )
})

test_that("latent, stochastic nodes", {
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = NA, latent = NA),
    nlist::nlists(nlist(
      x = 0.574752916346771, x2 = 0.912021637658974,
      y = 2, y2 = 0.912021637658974
    ))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = TRUE, latent = NA),
    nlist::nlists(nlist(x = 0.574752916346771, x2 = 0.912021637658974))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = FALSE, latent = NA),
    nlist::nlists(nlist(y = 2, y2 = 0.912021637658974))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = NA, latent = FALSE),
    nlist::nlists(nlist(x = 0.574752916346771, y2 = 0.912021637658974))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = NA, latent = TRUE),
    nlist::nlists(nlist(x2 = 0.912021637658974, y = 2))
  )
  # note the nodes monitored affects the random draws
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = TRUE, latent = FALSE),
    nlist::nlists(nlist(x = 0.342673102637473))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = TRUE, latent = TRUE),
    nlist::nlists(nlist(x2 = 0.912021637658974))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = FALSE, latent = FALSE),
    nlist::nlists(nlist(y2 = 0.912021637658974))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x2 ~ dnorm(y,1)
                              y <- 2
                              y2 <- x2", stochastic = FALSE, latent = TRUE),
    nlist::nlists(nlist(y = 2))
  )
})

test_that("latent, stochastic nodes with dots on end", {
  set.seed(101)
  expect_equal(
    sims_simulate("x ~ dunif(0,1)
                              x. ~ dnorm(y,1)
                              y <- 2
                              y. <- x.", stochastic = NA, latent = TRUE),
    nlist::nlists(nlist(x. = 0.912021637658974, y = 2))
  )
})

test_that("handles =", {
  set.seed(101)
  expect_error(
    sims_simulate("Y = beta + epsilon
      beta ~ dnorm(0,1)
      epsilon ~ dnorm(0,1)", nsim = 1, stochastic = TRUE, latent = FALSE),
    "^JAGS code must include at least one observed stochastic variable node[.]$"
  )

  set.seed(101)
  expect_equal(
    sims_simulate("Y = beta + epsilon
      beta ~ dnorm(0,1)
      epsilon ~ dnorm(0,1)", nsim = 1, latent = TRUE),
    nlist::nlists(nlist(beta = 0.51630333187765, epsilon = -1.08797836234103))
  )

  set.seed(101)
  expect_equal(
    sims_simulate("Y = beta + epsilon
      beta ~ dnorm(0,1)
      epsilon ~ dnorm(0,1)", nsim = 1, latent = NA, stochastic = NA),
    nlist::nlists(nlist(
      Y = -0.571675030463376, beta = 0.51630333187765,
      epsilon = -1.08797836234103
    ))
  )
})

test_that("with [] latent variables", {
  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dt(theta[1],theta[2],df)",
      parameters = nlist(df = 1, theta = c(1, 1))
    ),
    nlist::nlists(nlist(a = -0.787882623624165))
  )
})

test_that("strips comments before", {
  set.seed(101)
  expect_equal(
    sims_simulate("b ~ dnorm(a, 1)
                             # a ~ dunif(1)", parameters = list(a = 1)),
    nlist::nlists(nlist(b = -0.0879783623410262))
  )

  set.seed(101)
  expect_equal(
    sims_simulate("a ~ dunif(0,1)
                             # x <- a"),
    nlist::nlists(nlist(a = 0.342673102637473))
  )
})

test_that("with R code", {
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = NA),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = NA),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  set.seed(100)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = NA),
    nlist::nlists(nlist(a = 0.959129601367507))
  )
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = NA),
    nlist::nlists(nlist(a = 0.267390680177431))
  )

  expect_error(sims_simulate("a <- TRUE", stochastic = NA),
    "^All elements of simulations from `code` must be numeric[.]$",
    class = "chk_error"
  )

  expect_identical(
    sims_simulate("a <- 1
                             b <- a", stochastic = NA, latent = FALSE),
    nlist::nlists(nlist(b = 1))
  )

  expect_identical(
    sims_simulate("a <- 1
                             b <- a", stochastic = NA, latent = TRUE),
    nlist::nlists(nlist(a = 1))
  )

  expect_identical(
    sims_simulate("a <- 1
                             b <- a", stochastic = NA, latent = NA),
    nlist::nlists(nlist(a = 1, b = 1))
  )

  expect_identical(
    sims_simulate("a <- c
                             b <- a",
      stochastic = NA, latent = NA,
      constants = list(c = 2)
    ),
    nlist::nlists(nlist(a = 2, b = 2, c = 2))
  )
  expect_identical(
    sims_simulate("a <- c
                             b <- d",
      stochastic = NA, latent = NA,
      constants = list(c = 2), parameters = list(d = 3L)
    ),
    nlist::nlists(nlist(a = 2, b = 3L, c = 2))
  )
  expect_identical(
    sims_simulate("a <- c
                             b <- d",
      monitor = "b", stochastic = NA, latent = NA,
      constants = list(c = 2), parameters = list(d = 3L)
    ),
    nlist::nlists(nlist(b = 3L, c = 2))
  )
  expect_error(
    sims_simulate("a <- not_a_fun(c)", stochastic = NA),
    "could not find function \"not_a_fun\""
  )
})


test_that("with R code in parallel", {
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", nsims = 2, ),
    nlist::nlists(
      nlist(a = 0.637362094961879),
      nlist(a = 0.889581146657672)
    )
  )

  options(mc.cores = 2)
  future::plan(future::multisession)
  teardown(future::plan(future::sequential))

  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", nsims = 2),
    nlist::nlists(
      nlist(a = 0.637362094961879),
      nlist(a = 0.889581146657672)
    )
  )
})

test_that("with R code and single stochastic node", {
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = TRUE),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = NA),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)", stochastic = FALSE,
                  rdists = character(0)),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  expect_error(sims_simulate("a <- runif(1, 0, 1)",
    stochastic = FALSE, latent = FALSE
  ), "R code must include at least one observed deterministic variable node.")
  expect_error(sims_simulate("a <- runif(1, 0, 1)",
    stochastic = TRUE, rdists = character(0)
  ), paste0("^R code must include at least one stochastic variable node[.]",
  " Did you mean to set `rdists` = character[(]0[)]\\?$"))
})

test_that("with R code and stochastic and deterministic nodes", {
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             b <- 1", stochastic = TRUE),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             b <- 1", stochastic = NA),
    nlist::nlists(nlist(a = 0.637362094961879, b = 1))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             b <- 1",
                  stochastic = FALSE, rdists = character(0)),
    nlist::nlists(nlist(a = 0.637362094961879, b = 1))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             b <- 1", stochastic = FALSE),
    nlist::nlists(nlist(b = 1))
  )
})

test_that("with R code & stochastic & deterministic nodes & different rdist", {
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             runif <- 1
                             b <- runif", stochastic = TRUE),
    nlist::nlists(nlist(a = 0.637362094961879))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             runif <- 1
                             b <- runif", stochastic = NA, latent = FALSE),
    nlist::nlists(nlist(a = 0.637362094961879, b = 1))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             runif <- 1
                             b <- runif", stochastic = FALSE,
                  latent = FALSE, rdists = character(0)),
    nlist::nlists(nlist(a = 0.637362094961879, b = 1))
  )
  set.seed(101)
  expect_equal(
    sims_simulate("a <- runif(1, 0, 1)
                             runif <- 1
                             b <- runif", stochastic = FALSE, latent = FALSE),
    nlist::nlists(nlist(b = 1))
  )
})

test_that("save parallel", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  teardown(unlink(tempdir, recursive = TRUE))

  set.seed(1)

  options(mc.cores = 2)
  future::plan(future::multisession)
  teardown(future::plan(future::sequential))

  expect_true(sims_simulate("a ~ dunif(0,1)",
    save = TRUE, exists = FALSE,
    path = tempdir,
    ask = FALSE
  ))
  # sort to ensure matching order on all operating systems
  expect_identical(
    sort(list.files(tempdir, all.files = TRUE, recursive = TRUE)),
    sort(c(".sims.rds", "data0000001.rds"))
  )
})

test_that("simulate array", {
  set.seed(10)
  sims <- sims::sims_simulate("for(i in 1:2) {
  M[i,1] ~ dnorm(0,1)
  M[i,2] <- 2}")
  expect_equal(sims, nlist::nlists(nlist(M = matrix(c(
    0.750048077250373,
    -0.52435401319, 2, 2
  ), nrow = 2))))
})

test_that("progress", {
  set.seed(1)
  progressr::with_progress(x <- sims_simulate("a ~ dunif(0,1)", nsims = 1L))
  expect_equal(
    x,
    nlist::nlists(nlist(a = 0.749735354622374))
  )

  skip("only visually test sims progress bar at console")
  progressr::with_progress(sims_simulate("a ~ dunif(0,1)", nsims = 1000L))
})

test_that("save getwd", {
  skip("only test getwd at console")
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  teardown(unlink(tempdir, recursive = TRUE))

  set.seed(1)

  dir.create(tempdir)
  wd <- setwd(tempdir)
  on.exit(setwd(wd))
  expect_true(sims_simulate("a ~ dunif(0,1)",
    save = TRUE, exists = NA,
    ask = FALSE
  ))
  expect_identical(
    list.files(tempdir, all.files = TRUE, recursive = TRUE),
    c(".sims.rds", "data0000001.rds")
  )
})
