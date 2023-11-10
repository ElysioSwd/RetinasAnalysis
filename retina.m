clear;
close all;

folder = 'C:\Users\eyalg\Desktop\RetinasAnalysis\Base11';
fileList = dir(fullfile(folder, '/*.tif'));
randomIndex = randi(length(fileList), 1, 1); % Get a random number.
fullFileName = fullfile(folder, fileList(randomIndex).name);
image_originale = imread(fullFileName);

% Display the original image
figure;
imshow(image_originale);
title('Image originale');

% Display the green channel
figure;
canal_vert = image_originale;
canal_vert(:,:,1) = 0;
canal_vert(:,:,3) = 0;
imshow(canal_vert);
title('Canal Vert');

% Display the grayscale image
figure;
niveaux_de_gris = rgb2gray(image_originale);
imshow(niveaux_de_gris);
title('Niveaux de gris');

% Display the filtered image
figure;
Resized_Image = imresize(image_originale, [584 565]);
Converted_Image = im2double(Resized_Image);
Lab_Image = rgb2lab(Converted_Image);
fill = cat(3, 1, 0, 0);
Filled_Image = bsxfun(@times, fill, Lab_Image);
Reshaped_Lab_Image = reshape(Filled_Image, [], 3);
[C, S] = pca(Reshaped_Lab_Image);
S = reshape(S, size(Lab_Image));
S = S(:, :, 1);
Gray_Image = (S - min(S(:))) / (max(S(:)) - min(S(:)));
Enhanced_Image = adapthisteq(Gray_Image, 'numTiles', [8 8], 'nBins', 128);
Avg_Filter = fspecial('average', [9 9]);
Filtered_Image = imfilter(Enhanced_Image, Avg_Filter);
imshow(Filtered_Image);
title("Résultats de l'extraction");

% Display the binarized image
figure;
Subtracted_Image = imsubtract(Filtered_Image, Enhanced_Image);
level = Threshold_Level(Subtracted_Image);
Binary_Image = imbinarize(Subtracted_Image, level - 0.008);
imshow(Binary_Image);
title('Image binarisée');

% Display the generated mask
figure;
masque = imfill(Binary_Image, 'holes');
imshow(masque);
title('Génération du masque');

% Display the segmented image
figure;
Clean_Image = bwareaopen(Binary_Image, 100);
imshow(Clean_Image);
title('Image segmentée');

% Display the skeletonized image
figure;
skeletonImage = bwmorph(Clean_Image, 'skel', Inf);
imshow(skeletonImage);
title('Image squelettisée');

% Find endpoints
endpoints = bwmorph(skeletonImage, 'endpoints');

% Find junction points
junctions = bwmorph(skeletonImage, 'branchpoints');

% Display the original image with endpoints and junctions
figure;
imshow(skeletonImage);
hold on;

% Extract coordinates of endpoints and junctions
[endpoint_y, endpoint_x] = find(endpoints);
[junction_y, junction_x] = find(junctions);

% Plot endpoints in red
plot(endpoint_x, endpoint_y, 'ro', 'MarkerSize', 10);

% Plot junctions in blue
plot(junction_x, junction_y, 'bo', 'MarkerSize', 10);

hold off;
title('Endpoints and Junctions Detection');

% Plot endpoints and junctions in a graph
figure;
plot(endpoint_x, endpoint_y, 'ro', 'MarkerSize', 10);
hold on;
plot(junction_x, junction_y, 'bo', 'MarkerSize', 10);

% Customize the plot
xlabel('X-coordinate');
ylabel('Y-coordinate');
title('Endpoints and Junctions Detection');
legend('Endpoints', 'Junctions');
grid on;
hold off;



function level = Threshold_Level(Image)
    Image = im2uint8(Image(:));
    [Histogram_Count, Bin_Number] = imhist(Image);

    i = 1;

    Cumulative_Sum = cumsum(Histogram_Count);
    T(i) = (sum(Bin_Number .* Histogram_Count)) / Cumulative_Sum(end);

    T(i) = round(T(i));

    Cumulative_Sum_2 = cumsum(Histogram_Count(1:T(i)));
    MBT = sum(Bin_Number(1:T(i)) .* Histogram_Count(1:T(i))) / Cumulative_Sum_2(end);

    Cumulative_Sum_3 = cumsum(Histogram_Count(T(i):end));
    MAT = sum(Bin_Number(T(i):end) .* Histogram_Count(T(i):end)) / Cumulative_Sum_3(end);

    i = i + 1;
    T(i) = round((MAT + MBT) / 2);

    % Ensure that T(i) and T(i+1) are distinct initially
    while T(i) == T(i - 1)
        T(i) = T(i) + 1;
    end

    while abs(T(i) - T(i - 1)) >= 1
        Cumulative_Sum_2 = cumsum(Histogram_Count(1:T(i)));
        MBT = sum(Bin_Number(1:T(i)) .* Histogram_Count(1:T(i))) / Cumulative_Sum_2(end);

        Cumulative_Sum_3 = cumsum(Histogram_Count(T(i):end));
        MAT = sum(Bin_Number(T(i):end) .* Histogram_Count(T(i):end)) / Cumulative_Sum_3(end);

        i = i + 1;
        T(i) = round((MAT + MBT) / 2);

        Threshold = T(i);
    end

    level = (Threshold - 1) / (Bin_Number(end) - 1);
end
