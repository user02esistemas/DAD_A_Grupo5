/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Interfaces.IAuthRemoto;
import entidades.Clientes;
import entidades.Empleados;
import conexion.connectionDrive;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;

public class AuthDAO extends UnicastRemoteObject implements IAuthRemoto {

    public AuthDAO() throws RemoteException {
        super();
    }

    @Override
    public Clientes loginCliente(String email, String password) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            TypedQuery<Clientes> query = em.createQuery(
                "SELECT c FROM Clientes c WHERE c.email = :email AND c.password = :pass", 
                Clientes.class
            );
            query.setParameter("email", email);
            query.setParameter("pass", password);
            
            java.util.List<Clientes> resultados = query.getResultList();
            if (resultados != null && !resultados.isEmpty()) {
                Clientes c = resultados.get(0);
                // Separamos la entidad del contexto de JPA para evitar actualizaciones automáticas
                em.detach(c);
                // Evitamos que RMI intente serializar listas "IndirectList" de EclipseLink
                c.setPedidosList(null);
                c.setCitasList(null);
                return c;
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null; 
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public Empleados loginAdmin(String codigo, String password) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            TypedQuery<Empleados> query = em.createQuery(
                "SELECT e FROM Empleados e WHERE e.codigoEmpleado = :cod AND e.password = :pass AND e.estado = true", 
                Empleados.class
            );
            query.setParameter("cod", codigo);
            query.setParameter("pass", password);
            
            java.util.List<Empleados> resultados = query.getResultList();
            if (resultados != null && !resultados.isEmpty()) {
                Empleados e = resultados.get(0);
                em.detach(e);
                e.setPedidosList(null);
                return e;
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}