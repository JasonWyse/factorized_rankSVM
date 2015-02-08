use strict;
use Cwd;

#my $dir_name = $ARGV[0];
my $max_ite_num = $ARGV[0];
my $dataset_dir = '.';
opendir(DIR, $dataset_dir) || die "Can't open directory $dataset_dir";
my @models = readdir(DIR);
my %hs_rankSVM_result;
my %hs_rankSVM_fac_result;
my $fnOut = './result.txt';

foreach  (@models){
# we use a hash table to store the C   
        #for every model we 
        if (/rankSVM/)
        {
                my $result;


                if($_ eq 'rankSVM_fac')
                {
                         $result = \%hs_rankSVM_fac_result;
                         #print 'rankSVM_fac'."\n";
                }
                elsif ($_ eq 'rankSVM')
                {
                         $result = \%hs_rankSVM_result;
                         #print 'rankSVM'."\n";
                }
                my $model_dir = $dataset_dir.'/'.$_.'/';
                #print $model_dir;
                opendir(MODEL_DIR, $model_dir) || die "Can't open directory $model_dir";
                my @folds = readdir(MODEL_DIR);
                foreach (@folds)
                {
                        if(/Fold/)
                        {
                                my $fold_dir = $model_dir.$_.'/';
                                #print "\n".$fold_dir."\n";
                                #(my %tmp1,my %tmp2)
                                my  (%result_a, %result_b);
                                my ($result_a_ref, $result_b_ref);
                                ($result_a_ref, $result_b_ref)  =  BestVali_TestResult($fold_dir,$max_ite_num);
                                %result_a = %$result_a_ref;
                                %result_b = %$result_b_ref;
                                my %hs_C_vali_map = %result_a;
                                my %hs_C_test_NDCG = %result_b;
                                my @k = sort {$hs_C_vali_map{$b} <=> $hs_C_vali_map{$a}} keys %hs_C_vali_map;

                                $$result{$_} = $hs_C_test_NDCG{$k[0]};
                                # print $hs_C_test_NDCG{$k[0]}."\n";
                                # print $$result{$_}."\n";                              
                        }
                }
                #print %hs_rankSVM_fac_result;
        }

}
#print %hs_rankSVM_fac_result;
OutputResult($fnOut,\%hs_rankSVM_result,\%hs_rankSVM_fac_result);


sub OutputResult
{
        my ($fnOut,$hs1,$hs2) ;
        ($fnOut,$hs1,$hs2)= @_;
        my %hs_rankSVM_result = %$hs1;
        my %hs_rankSVM_fac_result = %$hs2;
        # print %hs_rankSVM_result;
        # print %hs_rankSVM_fac_result;
    open(FILE, ">$fnOut");
        print FILE "rankSVM\n";
        print FILE "\tMAP\tNDCG\@1\tNDCG\@3\tNDCG\@5\tNDCG\@10\n";
        my @sum_rankSVM;
        my @mean_rankSVM;
        for( my$i = 1 ;$i <= 5 ; ++$i)
        {
                print FILE "Fold$i\t".$hs_rankSVM_result{"Fold$i"}."\n";
                my @tmp=split(/\t/,$hs_rankSVM_result{"Fold$i"}); #@fields = split(/:/, "1:2:3:4:5");

                for(my $j = 0;$j<$#tmp+1;$j++)
                {
                        $sum_rankSVM[$j]+=$tmp[$j];
                }
        }

        for( my$i = 0 ;$i < 5 ; ++$i)
        {
                $mean_rankSVM[$i] = $sum_rankSVM[$i]/5;
        }
        print FILE "Mean\t";
        for( my$i = 0 ;$i < 5 ; ++$i)
        {
                print FILE sprintf("%.4f\t",$mean_rankSVM[$i]);
        }
        print FILE "\n";
        # print FILE "Fold1\t";#.$hs_rankSVM_result{"Fold1"};

        my @sum_rankSVM_fac;
        my @mean_rankSVM_fac;
    print FILE "\nrankSVM_fac\n";
        print FILE "\tMAP\tNDCG\@1\tNDCG\@3\tNDCG\@5\tNDCG\@10\n";
        for(my $i = 1; $i <= 5; $i ++)
        {
                print FILE "Fold$i\t".$hs_rankSVM_fac_result{"Fold$i"}."\n";
                my @tmp=split(/\t/,$hs_rankSVM_fac_result{"Fold$i"});

                for(my $j = 0;$j<$#tmp+1;$j++)
                {
                        $sum_rankSVM_fac[$j]+=$tmp[$j];
                }
        }

        for( my$i = 0 ;$i < 5 ; ++$i)
        {
                $mean_rankSVM_fac[$i] = $sum_rankSVM_fac[$i]/5;
        }
        print FILE "Mean\t";
        for( my$i = 0 ;$i < 5 ; ++$i)
        {
                print FILE sprintf ("%.4f\t",$mean_rankSVM_fac[$i]);
        }
        print FILE "\n";
}

sub BestVali_TestResult
{
        my $fold_dir = $_[0];
        my $max_ite_num = $_[1];
        #print $fold_dir."\n";
        my %hs_C_vali_map;
        my %hs_C_test_NDCG;
        #print $fold_dir."\n";
        opendir(FOLD_DIR, $fold_dir) || die "Can't open directory $fold_dir";
        my @C_set = readdir(FOLD_DIR);
        #iterate each C_value folder
        foreach (@C_set)
        {
                my $C_dir = $fold_dir.$_.'/';

                if(-d $C_dir)
                {       #filter "." and ".." in the current directory
                        if($C_dir = /\.*\d+\.*/)
                        {
                                #my $C_dir = $model_dir.'/'.$_.'/'."\n";
                                my $C_dir = $fold_dir.$_.'/';
                                my $C_value = $_;
                                my $real_max_ite_num = exist_MaxIteNum($C_dir);
                                if($real_max_ite_num < $max_ite_num)
                                {
                                        $max_ite_num = $real_max_ite_num;
                                }
                                #print $C_value."\n";
                                opendir(C_DIR, $C_dir) || die "Can't open directory $C_dir";
                                my @file_names = readdir(C_DIR);
                                foreach (@file_names)
                                {
                                        if(/NDCG_vali_ite$max_ite_num.*/)#choose the max iterate vali
                                        {
                                                #just find the exact vali max_ite_num file and read it
                                                my $vali_maxIteNum_fileName = $C_dir.$_;
                                                #$hs_C_vali_map{$C_value} = get_MAP($vali_maxIteNum_fileName);;
												$hs_C_vali_map{$C_value} = get_MeanNDCG($vali_maxIteNum_fileName);;
                                                # print $vali_maxIteNum_fileName."\n";
                                                # print $hs_C_vali_map{$C_value}."\n" ;


                                        }
                                        elsif(/NDCG_test_ite$max_ite_num.*/)
                                        {
                                                my $test_maxIteNum_fileName = $C_dir.$_;
                                                #print $test_maxIteNum_fileName."\n";
                                                my ($tmp1,$tmp2);
                                                # ($tmp1,$tmp2) = get_MAP_NDCG($test_maxIteNum_fileName);
                                                $hs_C_test_NDCG{$C_value} = get_NDCG($test_maxIteNum_fileName);
                                                #print $hs_C_test_NDCG{$C_value}."\n";
                                        }
                                }
                        }
                }
        }

        return (\%hs_C_vali_map,\%hs_C_test_NDCG);
        my %tmp;
        $tmp{'1'} = %hs_C_vali_map;
        $tmp{'2'} = %hs_C_test_NDCG;
        return %tmp;
        return %hs_C_vali_map;
}

sub exist_MaxIteNum
{
        my $C_dir = $_[0];
        opendir(C_DIR, $C_dir) || die "Can't open directory $C_dir";
        my @file_names = readdir(C_DIR);
        my $real_max_ite_num = 1;
        foreach (@file_names)
        {
                my $num = ($_ =~ /NDCG_vali_ite(\d+).*/);
                if(/NDCG_vali_ite\d+.*/)#choose the max iterate vali
                {
                        if($num>$real_max_ite_num)
                        {
                                $real_max_ite_num = $num;
                        }
                }
        }
        return $real_max_ite_num;
}

sub get_NDCG
{
        my $file_name = $_[0];
        my $map;
        my $set_ndcg;
        my $mean_ndcg;
        open(FILE, "<", $file_name) or die $!;
        my @array=<FILE>;
        my $index = -1;
        foreach (@array)
        {
                $index++;
                #print $index."\n";
                if($index == 2-1)
                {
                        chomp;
                        my @tmp=split(/\t/);
                        $map = @tmp[-1];

                }
                elsif ($index == 5-1)
                {
                        chomp;
                        my @tmp=split(/\t/);
                        #$vali_ite++;
                        $mean_ndcg = (@tmp[1]+@tmp[3]+@tmp[5]+@tmp[10])/4;
                        $set_ndcg = $map."\t".@tmp[1]."\t".@tmp[3]."\t".@tmp[5]."\t".@tmp[10]."\t";

                }

        }
        close FILE;
        return $set_ndcg;
}

sub get_MeanNDCG
{
        my $file_name = $_[0];
        my $map;
        my $set_ndcg;
        my $mean_ndcg;
        open(FILE, "<", $file_name) or die $!;
        my @array=<FILE>;
        my $index = -1;
        foreach (@array)
        {
                $index++;
                #print $index."\n";
                if($index == 2-1)
                {
                        chomp;
                        my @tmp=split(/\t/);
                        $map = @tmp[-1];

                }
                elsif ($index == 5-1)
                {
                        chomp;
                        my @tmp=split(/\t/);
                        #$vali_ite++;
                        #$mean_ndcg = (@tmp[1]+@tmp[3]+@tmp[5]+@tmp[10])/4;
						$mean_ndcg = @tmp[11];
                        $set_ndcg = @tmp[1]."\t".@tmp[3]."\t".@tmp[5]."\t".@tmp[10]."\t";

                }

        }
        close FILE;
        return $mean_ndcg;

}

sub get_MAP
{
        my $file_name = $_[0];
        my $map;
        my $set_ndcg;
        my $mean_ndcg;
        open(FILE, "<", $file_name) or die $!;
        my @array=<FILE>;
        my $index = -1;
        foreach (@array)
        {
                $index++;
                #print $index."\n";
                if($index == 2-1)
                {
                        chomp;
                        my @tmp=split(/\t/);
                        $map = @tmp[-1];

                }
                elsif ($index == 5-1)
                {
                        chomp;
                        my @tmp=split(/\t/);
                        #$vali_ite++;
                        $mean_ndcg = (@tmp[1]+@tmp[3]+@tmp[5]+@tmp[10])/4;
                        $set_ndcg = @tmp[1]."\t".@tmp[3]."\t".@tmp[5]."\t".@tmp[10]."\t";

                }

        }
        close FILE;
        return $map;

}