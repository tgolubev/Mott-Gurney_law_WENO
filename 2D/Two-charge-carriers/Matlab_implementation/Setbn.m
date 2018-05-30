function bn = Setbn(Bernoulli_n_values, n_mob, Un)
global Cp num_cell num_elements n_topBC n_leftBC n_rightBC n_bottomBC N;

bn = zeros(num_elements,1);

index = 0;
    for j = 1:N
        if(j ==1)  %different for 1st subblock
            for i = 1:N
                index = index +1;
                if (i==1)  %1st element has 2 BC's
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*(n_leftBC(1) + n_bottomBC);  %NOTE: rhs is +Cp*Un, b/c diagonal elements are + here, flipped sign from 1D version                   
                elseif (i==N)
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*(n_rightBC(1) + n_bottomBC);
                else
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*n_bottomBC;
                end
            end
        elseif(j == N)  %different for last subblock
            for i = 1:N
                index = index +1;
                if (i==1)  %1st element has 2 BC's
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*(n_leftBC(N) + n_topBC);
                elseif (i==N)
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*(n_rightBC(N) + n_topBC);
                else
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*n_topBC;
                end
            end
        else %interior subblocks
            for i = 1:N
                index = index +1;
                if(i==1)
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*n_leftBC(j);
                elseif(i==N)
                    bn(index,1) = Cp*Un(i,j) + n_mob(i,j)*n_rightBC(j);
                else
                    bn(index,1) = Cp*Un(i,j);
                end
            end
        end
    end