/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Interfaces.IGestionClientesRemoto;
import entidades.Clientes;
import conexion.connectionDrive;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class ClienteDAO extends UnicastRemoteObject implements IGestionClientesRemoto {

    public ClienteDAO() throws RemoteException {
        super();
    }

    @Override
    public List<Clientes> listarClientes() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Clientes> lista = em.createQuery("SELECT c FROM Clientes c WHERE c.email <> 'Sin Email' AND c.email IS NOT NULL", Clientes.class).getResultList();
            for (Clientes c : lista) {
                em.detach(c);
                c.setPedidosList(null);
                c.setCitasList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public Clientes buscarClientePorId(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            Clientes c = em.find(Clientes.class, idCliente);
            if (c != null) {
                em.detach(c);
                c.setPedidosList(null);
                c.setCitasList(null);
            }
            return c;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean registrarCliente(Clientes cliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(cliente);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean actualizarCliente(Clientes cliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(cliente);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean eliminarCliente(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Clientes cli = em.find(Clientes.class, idCliente);
            if (cli != null) {
                em.remove(cli);
                tx.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}