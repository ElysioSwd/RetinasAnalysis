clear all;
close all;

% Remplacez 'nom_de_votre_image.jpg' par le nom de votre image.
image_3D = imread('Base11/20051019_38557_0100_PP.tif');

% Sélectionner le canal vert (G) de l'image 3D.
image_canal_vert = image_3D;
image_canal_vert(:,:,1) = 0;
image_canal_vert(:,:,3) = 0;

% Convertir l'image en niveaux de gris.
image_gris = rgb2gray(image_canal_vert);

% Optionnel : Vous pouvez également sauvegarder l'image en niveaux de gris si nécessaire.
imshow(image_canal_vert);

% Afficher l'image en niveaux de gris.
% imshow(image_gris);
