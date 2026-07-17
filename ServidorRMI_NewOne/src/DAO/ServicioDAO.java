/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Interfaces.IGestionServiciosRemoto;
import entidades.Servicios;
import entidades.Citas;
import conexion.connectionDrive;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class ServicioDAO extends UnicastRemoteObject implements IGestionServiciosRemoto {

    public ServicioDAO() throws RemoteException {
        super();
    }

    @Override
    public List<Servicios> listarServiciosDisponibles() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Servicios> lista = em.createQuery("SELECT s FROM Servicios s", Servicios.class).getResultList();
            for (Servicios s : lista) {
                em.detach(s);
                s.setDetallePedidoList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean agendarCita(Citas cita) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(cita);
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
    public List<Citas> listarCitasPendientes() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Citas> lista = em.createQuery("SELECT c FROM Citas c WHERE c.estado = 'Pendiente'", Citas.class).getResultList();
            for (Citas c : lista) {
                em.detach(c);
                if (c.getIdCliente() != null) {
                    entidades.Clientes cl = c.getIdCliente();
                    cl.setCitasList(null);
                    cl.setPedidosList(null);
                }
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}