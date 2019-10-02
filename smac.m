% ������
clear all;

% �O���[�o���ϐ��錾
global dt ddt nx ny dx dy ddx ddx2 ddy ddy2 re

% �p�����[�^�[
n = 25;% �i�q��
nx = 4 * n;% �������i�q��
ny = n;% % �������i�q��
loop = 20000;% �X�e�b�v��
re = 100;% ���C�m���Y��
dt = 0.02;% �^�C���X�e�b�v

% �z��̊m��
p = zeros(nx + 2, ny + 2);
u = zeros(nx + 1, ny + 2);
v = zeros(nx + 2, ny + 1);
phi = zeros(nx + 2, ny + 2);% �␳����
up = zeros(nx + 1,ny + 2);% �\�����x
vp = zeros(nx + 2,ny + 1);% �\�����x
divup = zeros(nx + 2, ny + 2);% �\�����x�̔��U
divu = zeros(nx + 2, ny + 2);% �A���̎��`�F�b�N�p
psi = zeros(nx + 1, ny + 2);% ����֐�
uu = zeros(nx+2,ny+2);
vv = zeros(nx+2,ny+2);

% ���Z���̍팸
dx = 5 / n;% �i�q��
dy = dx;
ddx = 1 / dx;
ddy = ddx;
ddx2 = ddx * ddx;
ddy2 = ddy * ddy;
ddt = 1 / dt;

% �N�[�������̊m�F
dt = min(dt, 0.25 * dx);
dt = min(dt, 0.2 * re * dx * dx);% 1���Ԃ̃X�e�b�v�ŗ��̂��ڗ��ɂ���Ĕ�яo���Ȃ��悤�ɂ���
dt = min(dt, 0.2 * re * dx * dx);% �g�U�̉e���̍l��

% ���������̑��
u(:,ny+2) = 1;% �S�̈���P�ɂ��邱�ƂŁA���^�C���X�e�b�v�łł������A���̕������𖞂����悤�ɂ��Ă���H

% ���E�����̐ݒ�P
un = 1;
uw = 1;% ������ 
us = 1;
ue = 0;% ���o��
vn = 0;
vw = 0;% ������
vs = 0;
ve = 0;% ���o��

% ��Q���ʒu�̒�`
object = zeros(nx + 2, ny + 2);% ���͊i�q�x�[�X�ŏ�Q�����`����B
center = [(nx + 2) / 6, (ny + 3) / 2];
[object] = DefineObjectArea(object, center);

for ita = 1 : loop
    
    disp(ita);
    
    % �C�������E�C������u,v,p�֋��E������K�p
    [u] = BoundaryConditionU(u, ue, uw, us, un);
    [v] = BoundaryConditionV(v, ve, vw, vs, vn);
    [p] = BoundaryConditionP(p);
    
    % ������up�̌v�Z
    [up] = ProvisionalVelocityU(u, v, p, up);
    
    % ������up�֋��E������K�p
    [up] = BoundaryConditionU(up, ue, uw, us, un);
    
    % ������vp�̌v�Z
    [vp] = ProvisionalVelocityV(u, v, p, vp);
    
    % ������vp�֋��E������K�p
    [vp] = BoundaryConditionV(vp, ve, vw, vs, vn);
    
    % ���������A���̕������𖞂����Ă��邩�m�F
    [div, divup] = CheackContinuousFormula(up, vp, divup);
    
    % ���͂̃|�A�\��������������
    eps = 10^(- 8);
    maxitr = nx * ny * 2;% �����񐔁B���������邽�߂ɂ͂��̂��炢�K�v�B
    alpha = 1.7;% �ɘa�W��
    [phi] = PoissonSolver(alpha, phi, eps, maxitr, divup, nx, ny, ddt, ddx2, ddy2);
    
    % �����x�E���͂̏C��
    [u, v, p] = ModifyVP(up, vp, u, v, p, phi);
    
    % �C���������A���̎��̖����x�`�F�b�N
    [div, divu] = CheackContinuousFormula(u, v, divu);
    
    % ��Q���̔z�u(�Z�����Ő�L���銄���ɂ���Ēl�����肷��B)
    for i = 1 : nx + 2
        for j = 1 : ny + 2
            if object(i, j) == 1% ��Q�������Ȃ�Βl���[���ɒu��
                u(i - 1, j) = 0;
                v(i, j - 1) = 0;
            elseif object(i, j) == 2% ��Q�����E�Ȃ�Βl�̔���
                u(i - 1, j) = 0.5 * u(i - 1, j);
                v(i, j - 1) = 0.5 * v(i, j - 1);
            end
        end
    end
    
    % ���͊i�q�ʒu�ł̑��x�����߂�B
    [uu, vv] = VelocityInterpolate(u, v, uu, vv);
    
    % ���ʂ̕`��
    vis_contour('u.gif', ita, uu, 0, 1.5, 1)
    %vis_contour('v.gif', ita, vv, -0.6, 0.6, 2)
    %vis_vector('vec.gif', ita, uu, vv, 3)
    
end

function[] = vis_contour(filename, timestep, u, maxrange, minrange, fignum)
% �X�J���[��̉���%
% Input
% ----------
% filename : text
%   �o��gif�t�@�C���̃t�@�C����
% timestep : numeric
%   �^�C���X�e�b�v
% u : matrix
%   ������
% maxrange : �X�J���[
%   �R���^�[�̍ő�l
% minrange : �X�J���[
%   �R���^�[�̍ŏ��l
% fignum : �X�J���[
% �@���Ԗڂ̕`�ʃE�B���h�E�ɏ������ނ�


% �O���[�o���ϐ��Ăяo��
global dt

figure(fignum);
imagesc(u)
view(0, 90);%���_�̐ݒ�
title(['time = ', num2str(timestep * dt, '%.3f')]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 16);
axis equal; axis tight; axis on;
colorbar
caxis([maxrange minrange])
frame = getframe(fignum);
im = frame2im(frame);
[imind, cm] = rgb2ind(im, 256);
if timestep == 1
    imwrite(imind, cm, filename, 'gif', 'DelayTime', 0.001, 'Loopcount', inf);
elseif rem(timestep, 10) == 0
    imwrite(imind, cm, filename, 'gif', 'DelayTime', 0.001, 'WriteMode', 'append');
end

end

function[] = vis_vector(filename, timestep, u, v, fignum)
% �x�N�g����̉���
% Input
% ----------
% filename : text
%   �o��gif�t�@�C���̃t�@�C����
% timestep : numeric
%   �^�C���X�e�b�v
% u : matrix
%   x�����x�N�g��
% v : matrix
%   y�����x�N�g��
% fignum : �X�J���[
% �@���Ԗڂ̕`�ʃE�B���h�E�ɏ������ނ�

% �O���[�o���ϐ��Ăяo��
global dt nx ny

figure(fignum);
quiver(flipud(rot90(u)),flipud(rot90(v)),'r')
title(['time = ', num2str(timestep * dt, '%.3f')]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 16);
axis equal; axis tight; axis on;
xlim([0 nx]);
ylim([0 ny]);
frame = getframe(fignum);
im = frame2im(frame);
[imind, cm] = rgb2ind(im, 256);
if timestep == 1
    imwrite(imind, cm, filename, 'gif', 'DelayTime', 0.001, 'Loopcount', inf);
elseif rem(timestep, 10) == 0
    imwrite(imind, cm, filename, 'gif', 'DelayTime', 0.001, 'WriteMode', 'append');
end

end

function[uu, vv] = VelocityInterpolate(u, v, uu, vv)

% �O���[�o���ϐ��Ăяo��
global nx ny

for i = 1 : nx + 2
    for j = 1 : ny + 2
        if i == 1 % �������Ȃ��
            uu(i, j) = 0.5 * (3 * u(i, j) - u(i + 1, j));
        elseif  i == nx + 2 %���o���Ȃ��
            uu(i, j) = 0.5 * (3 * u(i - 1, j) - u(i - 2, j));
        else% �����̈�
            uu(i, j) = 0.5 * (u(i, j) + u(i - 1, j));%
        end
    end
end
for i = 1 : nx + 2
    for j = 1 : ny + 2
        if j == 1
            vv(i, j) = 0.5 * (3 * v(i, j) - v(i, j + 1));%��ލ����ߎ�
        elseif j == ny + 2
            vv(i, j) = 0.5 * (3 * v(i, j - 1) - v(i, j - 2));%��ލ����ߎ�
        else
            vv(i, j) = 0.5 * (v(i, j) + v(i, j - 1));%�O�i�����ߎ�
        end
    end
end

end

function[div, divup] = CheackContinuousFormula(up, vp, divup)

% �O���[�o���ϐ��Ăяo��
global nx ny ddx ddy

ic = 0;
div = 0;
for j = 2 : ny + 1
    for i = 2 : nx + 1
        divup(i, j) = ddx * (up(i, j) - up(i - 1, j)) + ddy * (vp(i, j) - vp(i,j - 1));
        ic = ic + 1;
        div = div + divup(i, j)^2;
    end
end

end

function[u, v, p] = ModifyVP(up, vp, u, v, p, phi)

% �O���[�o���ϐ��Ăяo��
global nx ny ddx ddy dt

for j = 2 : ny + 1
    for i = 2 : nx
        u(i, j) = up(i, j) - dt * ddx * (phi(i + 1, j)-phi(i, j));%���Q�V
    end
end
for j = 2 : ny
    for i = 2 : nx + 1
        v(i, j) = vp(i, j) - dt * ddy * (phi(i, j + 1) - phi(i, j));%���Q�X
    end
end
for j = 2 : ny + 1
    for i = 2 : nx + 1
        p(i, j) = p(i, j) + phi(i, j);%���R�P
    end
end

end

function[phi] = PoissonSolver(alpha, phi, eps, maxitr, divup, nx, ny, ddt, ddx2, ddy2)

% �O���[�o���ϐ��g���ƒx���Ȃ邩��g��Ȃ��B

for iter = 1 : maxitr% SOR�@�ɂ�舳�͕␳�l�����߂�B
    error = 0;
    for j = 2 : ny + 1
        for i = 2 : nx + 1
            rhs = ddt * divup(i, j);%���Q�T�E��
            resid = ddx2 * (phi(i - 1,j) - 2 * phi(i, j) + phi(i + 1, j))...
                + ddy2 * (phi(i, j - 1) - 2 * phi(i, j)+phi(i, j + 1)) - rhs;
            dphi = alpha * resid / (2 * (ddx2 + ddy2));
            error = max(abs(dphi), error);
            phi(i, j) = phi(i, j) + dphi;%���Q�T��phi(i,j)�ɂ��Ă܂Ƃ�SOR�@�̌`�ɂ�������
        end
    end
    
    % ���E�����̐ݒ�
    phi(1, 2 : ny + 1) = phi(2, 2 : ny + 1);%�����ł̈��͌��z�O�B
    phi(nx + 2, 2 : ny + 1) = 0;%�������E����
    phi(2 : nx + 1, 1) = phi(2 : nx + 1, 2);%�쑤���E����
    phi(2 : nx + 1, ny + 2) = phi(2 : nx + 1, ny + 1); %�k�����E����
    
    if error < eps % �����������������ꂽ�烋�[�v�𔲂���B
        break
    end
    
    if iter >= maxitr
        disp('�ő唽���񐔂ɒB���܂����B���������𖞂����Ă��܂���B');
    end
end

end

function[up] = ProvisionalVelocityU(u, v, p, up)

% �O���[�o���ϐ��Ăяo��
global nx ny ddx ddy ddx2 ddy2 re dt

for j = 2 : ny + 1
    for i = 2 : nx % temporary u-velocity
        %u�iij�j���S�Ōv�Z
        %�ڗ����̗��U��
        cnvu = ddx * ((u(i + 1, j) + u(i, j))^2 - (u(i - 1, j) + u(i, j))^2) / 4 ...
            + ddy * ((u(i, j + 1) + u(i, j)) * (v(i + 1, j)+v(i, j))...
            -(u(i, j) + u(i, j - 1)) * (v(i, j - 1) + v(i + 1, j - 1))) / 4;
        fij = - ddx * (p(i + 1, j) - p(i, j)) - cnvu...
            + ddx2 * (u(i + 1, j) - 2 * u(i, j) + u(i - 1, j)) / re...
            + ddy2 * (u(i, j + 1) - 2 * u(i, j) + u(i, j - 1))/ re;
        up(i, j) = u(i, j) + dt * fij;
    end
end

end

function[vp] = ProvisionalVelocityV(u, v, p, vp)

% �O���[�o���ϐ��Ăяo��
global nx ny ddx ddy ddx2 ddy2 re dt

for j = 2 : ny
    for i = 2 : nx + 1% temporary v-velocity
        % v�iij�j���S��d�v�Z
        % �ڗ����̗��U��
        cnvv = ddx * ((u(i, j + 1) + u(i, j)) * (v(i + 1, j)+v(i, j))...
            - (u(i - 1, j + 1) + u(i - 1, j)) * (v(i - 1, j)+v(i, j))) / 4 ...
            + ddy * ((v(i, j + 1) + v(i, j))^2 - (v(i, j) + v(i, j - 1))^2) / 4;
        gij = - ddy * (p(i, j + 1) - p(i, j)) - cnvv...
            + ddx2 * (v(i + 1, j) - 2 * v(i, j) + v(i - 1, j)) / re...
            + ddy2 * (v(i,j + 1) - 2 * v(i, j) + v(i, j - 1)) / re;
        vp(i, j) = v(i, j) + dt * gij;
    end
end

end

function[u] = BoundaryConditionU(u, ue, uw, us, un)

% �O���[�o���ϐ��Ăяo��
global nx ny

u(nx + 1, 1 : ny + 1) = u(nx,1 : ny + 1);% ���x���z�O
u(1, 1 : ny + 1) = uw; % �����i�������j���E����
u(1 : nx + 1, 1) = us; % �쑤���E����
u(1 : nx + 1, ny + 2) = un; % �k�����E����

end

function[v] = BoundaryConditionV(v, ve, vw, vs, vn)

% �O���[�o���ϐ��Ăяo��
global nx ny

v(2 : nx + 1, 1) = vs;% �쑤���E����
v(2 : nx + 1, ny + 1) = vn;% �k�����E����
v(1, 2 : ny) = vw;% �������E�����B�[�_�͐����ɂ͊܂߂��A���A��ƍl����B
v(nx + 2, 2 : ny) = v(nx + 1, 2 : ny);% �����̑��x���z�O

end

function[p] = BoundaryConditionP(p)

% �O���[�o���ϐ��Ăяo��
global nx ny

p(nx + 2, 1 : ny + 1) = 0;% �����i���o���j���E���� ���͂O
p(1, 1 : ny + 1) = p(2, 1 : ny + 1);% �����i�������j���E����
p(1 : nx + 1, 1) = p(1 : nx + 1, 2);% �쑤���E����
p(1 : nx + 1, ny + 2) = p(1 : nx + 1, ny + 1);% �k�����E����

end

function[object] = DefineObjectArea(object, center)

% �O���[�o���ϐ��Ăяo��
global nx ny dx dy

% ��Q���̈�̒�`
for i = 1 : nx + 2
    for j = 1 : ny + 2
        r = sqrt(((i - center(1)) * dx)^2 + ((j - center(2)) * dy)^2);%���S����i�q�_�܂ł̋���
        if r < 2.5 * dx
            object(i, j) = 1;% ��Q���̈ʒu��1�Ƃ���B
        end
    end
end
% ��Q�����E�̈�̒��o
[row1, col1] = find(object > 0);
for i = 1: size(row1)
    if object(row1(i) - 1, col1(i)) == 0 || object(row1(i), col1(i)-1)==0 ||...
            object(row1(i)+1, col1(i)) == 0 || object(row1(i),col1(i)+1) == 0
        object(row1(i), col1(i)) = 2;%�p���̋��E���Q�Ƃ���B
    end
end

end
