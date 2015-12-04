<?php
$r = enchant_broker_init();
$bprovides = enchant_broker_describe($r);
echo "Current broker provides the following backend(s):\n";
print_r($bprovides);

$dicts = enchant_broker_list_dicts($r);
print_r($dicts);

// voikko and enchant only offers fi as of now (20151204)
// se is packaged as fi can be downloaded from
// http://divvun.no/static_files/zhfsts/se_avvir.zhfst
$tag = 'fi';
if (enchant_broker_dict_exists($r,$tag)) {
    $d = enchant_broker_request_dict($r, $tag);
    $dprovides = enchant_dict_describe($d);
    echo "dictionary $tag provides:\n";
    $wordcorrect = enchant_dict_check($d, "nuvviDspeller");
    print_r($dprovides);
    if (!$wordcorrect) {
        $suggs = enchant_dict_suggest($d, "nuvviDspeller");
        echo "Suggestions for 'nuvviDspeller':";
        print_r($suggs);
    }
    enchant_broker_free_dict($d);
}
enchant_broker_free($r);
?>
