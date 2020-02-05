%%
%Read in the image
raw_im = imread('your_segmented_image.tiff');

%Read in data file
datafile = readtable('your_pseudotime_value_for_each_segmented_cell.csv');

%Convert to black and white
bw_im = rgb2gray(raw_im);

%Show the image
figure(1)
clf
imshow(bw_im,[])

%Each region does not have a unique color. Find unique labels.
raw_labels = double(unique(bw_im));
raw_labels = raw_labels(raw_labels > 0);

label_matrix = zeros(size(bw_im));

%Loop through and assign unique labels to each region.
offset = 0;
for ii = 1:numel(raw_labels)
    
    mask_ii = (bw_im == raw_labels(ii));
    label_ii = bwlabel(mask_ii);

    label_ii(label_ii>0) = label_ii(label_ii>0)+offset;
    
    label_matrix = label_matrix+label_ii;
    
    clf
    imshow(label_matrix,[])
    offset = max(label_matrix(:));
end


%Loop through table, find reg label at each centroid, assing pseudotime to
%all pixels with same value
psu_im = zeros(size(bw_im));

figure(2)
clf
imshow(label_matrix,[])
hold on;

for ii = 1:size(datafile,1)
    
cenx = round(datafile.Location_Center_X(ii));
ceny = round(datafile.Location_Center_Y(ii));
psu = datafile.Pseudotime(ii); % 'Pseudotime' can be replaced with the column name for the pseudotime value in your file. 

%Get the label at centroid
label = label_matrix(ceny,cenx);
psu_im(label_matrix == label) = psu;
end

psu_im(bw_im == 0) = 0;
c = colormap(parula);
c = [[0,0,0];c];

figure(1)
clf;
imshow(psu_im,[]);
colormap(figure(1), parula)


