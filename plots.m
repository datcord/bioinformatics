results11 = importdata("results11");
results15 = importdata("results15");
results21 = importdata("results21");

x1 = results11(:,1);
y1 = results11(:,2);

figure();
plot(x1,y1,'linewidth',2);
xlabel('Amino Acid Number, Window size: 11');
ylabel('Sliding Window Result');

x2 = results15(:,1);
y2 = results15(:,2);

figure();
plot(x2,y2,'linewidth',2);
xlabel('Amino Acid Number, Window size:15');
ylabel('Sliding Window Result');

x3 = results21(:,1);
y3 = results21(:,2);

figure();
plot(x3,y3,'linewidth',2);
xlabel('Amino Acid Number, Window size:21');
ylabel('Sliding Window Result');


