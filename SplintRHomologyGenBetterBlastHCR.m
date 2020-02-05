%Generates probes for multiplex experiment

%Reads from xlx file the names of accession numbers
clear all;

[num,txt,raw] = xlsread('your_genelist.xlsx');

probelength = 52;
spacerlength = 3;

GC_cutoff = [40 66];
mkdir('HomologyRegionsHCR');
for genes = 1:length(txt(:,2))-1
%for genes=3
    
    accession = txt{genes+1,2}; %Refseq Accession numbers in second column
    if ~isempty(strfind(accession,'.'))
        accession = accession(1:strfind(accession,'.')-1); %get rid of trailing .n
    end
    seq=genbankread('your_gene_sequences_sequence.gb');
    
    index = find(strcmp({seq.LocusName}, accession)==1)
    S = seq(index).Sequence;
    if isempty(seq(index).CDS)
        idx=[1,length(S)];
    else
        idx = seq(index).CDS.indices;
    end
    S = S(idx(1):end); %Start from beginning of CDS
    matchedgenename = regexp(seq(index).Definition, '\(\w*\),', 'match')
    if isempty(matchedgenename)
        'No matched gene name. Using default'
        genename = txt{genes+1,2}
    else
        genename = matchedgenename{1}(2:end-2)
    end  
  
    tail = probelength + spacerlength + 1; %index to where the tail of the probe design is
    probenum = 1;
    List = {};
    while tail < length(S)
        %blast against excluded sequences
        TempSeq = S((tail - probelength - spacerlength): tail-spacerlength -1);
        fastawrite('temp.fa', TempSeq); 
  
        hits = false;
        blasthits=false;
        %check for repeats of same base
        if seqwordcount(TempSeq,'CCCCC') > 0
            hits = true;
        end
        if seqwordcount(TempSeq,'GGGGG') > 0
            hits = true;
        end
        if seqwordcount(TempSeq,'AAAAA') > 0
            hits = true;
        end
        if seqwordcount(TempSeq,'TTTTT') > 0
            hits = true;
        end
        %BSRDI
        %restriction site exclusion
%         if seqwordcount(TempSeq,'GCAATG') > 0
%           hits = true;
%         end
        
        %BSAI
        %restriction site exclusion
        if seqwordcount(TempSeq,'GGTCTC') > 0
          hits = true;
        end
        if seqwordcount(TempSeq,'GAGACC') > 0
          hits = true;
        end
        
        
        
        %check GC
        seqProperties = oligoprop(TempSeq, 'HPBase', 7, 'HPLoop', 6, 'DimerLength', 10);
        if seqProperties.GC < GC_cutoff(1)
            hits = true;
        end
        if seqProperties.GC > GC_cutoff(2)
            disp(seqProperties.GC)
            hits = true;
        end
        %check for hairpins or dimers
        if ~isempty(seqProperties.Hairpins)  || ~isempty(seqProperties.Dimers)
            hits = true;
            disp('a')
        end
        
        
        %only blast if sequence properties are good
        if hits == false 
            blastout = blastlocal('InputQuery','temp.fa','Program','blastn','DataBase', 'mouserefseq.fna', 'blastargs', '-S 1 -F F');
            for i = 1:length(blastout.Hits)
                if isempty(strfind(blastout.Hits(i).Name, genename)) %ignore same gene
                        if isempty(strfind(blastout.Hits(i).Name, 'PREDICTED')) %ignore predicted
                            for j = 1:max(size(blastout.Hits(i).HSPs))
                                 if ~isempty(strfind(blastout.Hits(i).HSPs(j).Strand, 'Plus/Plus')) %Look for only Plus/Plus
                                     if blastout.Hits(i).HSPs(j).Identities.Match >25 %25 bases of identity or greater
                                            blastout.Hits(i).HSPs(j).Identities.Match
                                            if blastout.Hits(i).HSPs(j).QueryIndices(1) < 12 &&  blastout.Hits(i).HSPs(j).QueryIndices(2)>20 %well centered
                                               alignment = blastout.Hits(i).HSPs(j).Alignment
                                               blastout.Hits(i).Name
											    blasthits = true;
                                            end
                                     end
                                 end
                            end
                        end
                end
            end
            blastres{probenum} = blastout;
        end
            

        
        if blasthits==true
            tail=tail+8;        
        elseif hits == true
            tail = tail + 5; %shift window by 2 if probes not found
        else
            probeindx{probenum} = tail - probelength - spacerlength;
            tail = tail + probelength + spacerlength;
            List{probenum} = TempSeq;
            probenum = probenum + 1
        end
        delete('temp.fa');
    end
    for ii = 1:max(size(List))
        RevList{ii} = seqrcomplement(List{ii});
        mkdir('HomologyRegionsHCR') 
        oldfolder = cd('HomologyRegionsHCR');
        fasta.Sequence = RevList{ii};
        fasta.Header = ['probe' num2str(ii) ' index ' num2str(probeindx{ii})];
        fastawrite([accession '.fa'], fasta);
        cd(oldfolder);
    end
    clear probeindx;
    clear List;
   

end;